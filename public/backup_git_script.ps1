# 自动备份并提交到Git的PowerShell脚本
# 1. 备份当前ics-website目录到backup文件夹
# 2. 自动git add、commit、push

$src = "$PWD"
$backup = "$PWD\backup\$(Get-Date -Format 'yyyyMMdd_HHmmss')"

# 创建备份目录
New-Item -ItemType Directory -Path $backup -Force
# 复制所有文件
Copy-Item "$src\*" $backup -Recurse -Force

# Git操作
cd $src
# 添加所有更改
git add .
# 提交（自动生成时间戳注释）
git commit -m "自动备份: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
# 推送到远程仓库
try {
    git push
} catch {
    Write-Host "推送失败，请检查远程仓库配置。"
}

Write-Host "备份完成，已提交到Git并推送。"
