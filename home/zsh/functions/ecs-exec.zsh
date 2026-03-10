# ecs-exec: ECSコンテナへの接続・コマンド実行を対話的に行う関数
#
# 概要:
#   AWS ECSのコンテナにfzfで対話的に選択しながら接続する。
#   モード選択により、bashで直接接続するか、
#   run-taskでコマンドをワンショット実行するかを選べる。
#
# 使い方:
#   ecs-exec
#
# 依存:
#   - aws cli (brew install awscli)
#   - session-manager-plugin (brew install --cask session-manager-plugin)
#   - fzf (brew install fzf)
#   - jq (brew install jq)

function ecs-exec() {
  local profile cluster service task container
  local items

  # profile選択
  profile=$(aws configure list-profiles | fzf --prompt="profile > ")
  [ -z "$profile" ] && return

  # 認証チェック
  echo "認証情報を確認します"
  echo "\033[2m> aws sts get-caller-identity --profile $profile\033[0m"
  local identity
  identity=$(aws sts get-caller-identity --profile "$profile" 2>&1)
  if [ $? -ne 0 ]; then
    echo "$identity"
    echo "認証が切れています。SSO loginでブラウザ認証を行います"
    echo "\033[2m> aws sso login --profile $profile\033[0m"
    read -sk "?[Enter] "
    echo
    aws sso login --profile "$profile" || return 1
  else
    echo "$identity"
  fi
  echo

  # クラスター選択
  echo "ECSクラスター一覧を取得します"
  echo "\033[2m> aws ecs list-clusters --profile $profile\033[0m"
  items=$(aws ecs list-clusters --profile "$profile" --query "clusterArns[*]" --output text | tr '\t' '\n' | sed 's|.*/||')
  echo "$items"
  cluster=$(echo "$items" | fzf --prompt="cluster > ")
  [ -z "$cluster" ] && return

  # サービス選択
  echo "クラスター内のサービス一覧を取得します"
  echo "\033[2m> aws ecs list-services --cluster $cluster --profile $profile\033[0m"
  items=$(aws ecs list-services --cluster "$cluster" --profile "$profile" --query "serviceArns[*]" --output text | tr '\t' '\n' | sed 's|.*/||')
  echo "$items"
  service=$(echo "$items" | fzf --prompt="service > ")
  [ -z "$service" ] && return

  # タスク取得
  echo "実行中のタスクを取得します"
  echo "\033[2m> aws ecs list-tasks --cluster $cluster --service-name $service --profile $profile\033[0m"
  task=$(aws ecs list-tasks --cluster "$cluster" --service-name "$service" --profile "$profile" --query "taskArns[0]" --output text)
  if [ -z "$task" ] || [ "$task" = "None" ]; then
    echo "実行中のタスクが見つかりません"
    return 1
  fi
  echo "task: $(echo $task | sed 's|.*/||')"

  # コンテナ選択
  echo "タスク内のコンテナ一覧を取得します"
  echo "\033[2m> aws ecs describe-tasks --cluster $cluster --tasks $task --profile $profile\033[0m"
  items=$(aws ecs describe-tasks --cluster "$cluster" --tasks "$task" --profile "$profile" --query "tasks[0].containers[*].name" --output text | tr '\t' '\n')
  echo "$items"
  container=$(echo "$items" | fzf --prompt="container > ")
  [ -z "$container" ] && return

  # モード選択
  local mode
  mode=$(echo "bash接続 (execute-command)\nコマンド実行 (run-task)\n何もしない (exit)" | fzf --prompt="mode > ")
  [ -z "$mode" ] && return
  echo

  case "$mode" in
    "bash接続 (execute-command)")
      echo "コンテナにbashで接続します"
      echo "\033[2m> aws ecs execute-command --cluster $cluster --task $task --container $container --interactive --command /bin/bash --profile $profile\033[0m"
      read -sk "?[Enter] "
      echo
      aws ecs execute-command \
        --cluster "$cluster" \
        --task "$task" \
        --container "$container" \
        --interactive \
        --command "/bin/bash" \
        --profile "$profile"
      ;;

    "コマンド実行 (run-task)")
      # 複数コマンドの入力
      local -a cmds
      echo "実行するコマンドを入力してください (空行で入力終了):"
      while true; do
        local cmd
        echo -n "> "
        read cmd
        [ -z "$cmd" ] && break
        cmds+=("$cmd")
      done
      [ ${#cmds[@]} -eq 0 ] && return
      echo
      echo "${#cmds[@]}件のコマンドを順次実行します:"
      for i in {1..${#cmds[@]}}; do
        echo "  [$i] ${cmds[$i]}"
      done
      read -sk "?[Enter] "
      echo

      # 既存タスクからタスク定義とネットワーク設定を取得
      echo "既存タスクからタスク定義とネットワーク設定を取得します"
      echo "\033[2m> aws ecs describe-tasks --cluster $cluster --tasks $task --profile $profile\033[0m"
      read -sk "?[Enter] "
      echo
      local task_detail task_def subnets
      task_detail=$(aws ecs describe-tasks --cluster "$cluster" --tasks "$task" --profile "$profile" --output json)
      task_def=$(echo "$task_detail" | jq -r '.tasks[0].taskDefinitionArn')
      subnets=$(echo "$task_detail" | jq -r '[.tasks[0].attachments[0].details[] | select(.name=="subnetId") | .value] | join(",")')

      # セキュリティグループをENIから取得
      local eni_id sg
      eni_id=$(echo "$task_detail" | jq -r '.tasks[0].attachments[0].details[] | select(.name=="networkInterfaceId") | .value')
      sg=$(aws ec2 describe-network-interfaces --network-interface-ids "$eni_id" --profile "$profile" --query "NetworkInterfaces[0].Groups[*].GroupId" --output text | tr '\t' ',')

      echo "タスク定義: $task_def"
      echo "サブネット: $subnets"
      echo "セキュリティグループ: $sg"
      read -sk "?[Enter] "
      echo

      local log_group
      log_group=$(aws ecs describe-task-definition --task-definition "$task_def" --profile "$profile" --query "taskDefinition.containerDefinitions[?name=='$container'].logConfiguration.options.\"awslogs-group\"" --output text)

      # コマンドを順次実行
      for i in {1..${#cmds[@]}}; do
        echo "========================================="
        echo "[${i}/${#cmds[@]}] ${cmds[$i]}"
        echo "========================================="

        # コマンドをJSON配列に変換（クォートを含むコマンドに対応）
        local cmd_json
        cmd_json=$(python3 -c "import sys,json,shlex; print(json.dumps(shlex.split(sys.argv[1])))" "${cmds[$i]}")

        local overrides
        overrides=$(jq -n --arg name "$container" --argjson cmd "$cmd_json" \
          '{containerOverrides: [{name: $name, command: $cmd}]}')

        echo "run-taskを実行します"
        echo "\033[2m> aws ecs run-task --cluster $cluster --task-definition $task_def --overrides '...' --network-configuration '...' --profile $profile\033[0m"
        read -sk "?[Enter] "
        echo
        local run_result
        run_result=$(aws ecs run-task \
          --cluster "$cluster" \
          --task-definition "$task_def" \
          --overrides "$overrides" \
          --network-configuration "awsvpcConfiguration={subnets=[$subnets],securityGroups=[$sg],assignPublicIp=DISABLED}" \
          --launch-type FARGATE \
          --profile "$profile" \
          --output json)

        local new_task
        new_task=$(echo "$run_result" | jq -r '.tasks[0].taskArn')

        if [ -z "$new_task" ] || [ "$new_task" = "null" ]; then
          echo "タスクの起動に失敗しました"
          echo "$run_result" | jq .
          return 1
        fi

        local new_task_id
        new_task_id=$(echo "$new_task" | sed 's|.*/||')
        echo "タスクが起動しました: $new_task_id"
        echo "タスクの完了を待機しています..."
        echo "\033[2m> aws ecs wait tasks-stopped --cluster $cluster --tasks $new_task_id --profile $profile\033[0m"
        aws ecs wait tasks-stopped --cluster "$cluster" --tasks "$new_task_id" --profile "$profile"

        # 終了コードを確認
        local exit_code
        exit_code=$(aws ecs describe-tasks --cluster "$cluster" --tasks "$new_task_id" --profile "$profile" \
          --query "tasks[0].containers[?name=='$container'].exitCode" --output text)

        if [ "$exit_code" = "0" ]; then
          echo "\033[32m[${i}/${#cmds[@]}] 成功 (exit code: 0)\033[0m"
        else
          echo "\033[31m[${i}/${#cmds[@]}] 失敗 (exit code: $exit_code)\033[0m"
          echo "ログを確認するには:"
          echo "  aws logs tail $log_group --follow --profile $profile"
          if [ $i -lt ${#cmds[@]} ]; then
            echo -n "残りのコマンドを続行しますか？ (y/n): "
            local cont
            read -k1 cont
            echo
            [ "$cont" != "y" ] && return 1
          fi
        fi
        echo
      done

      echo "全コマンドの実行が完了しました"
      echo "ログを確認するには:"
      echo "  aws logs tail $log_group --follow --profile $profile"
      ;;

    "何もしない (exit)")
      echo "終了します"
      return 0
      ;;
  esac
}
