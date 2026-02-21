#!/bin/bash

# Cent 项目一键启动脚本
# 用于快速启动项目开发服务器

set -e  # 遇到错误立即退出

echo "=========================================="
echo "       Cent 项目一键启动"
echo "=========================================="
echo ""

# 项目目录
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 要求的 Node.js 版本
REQUIRED_NODE_MAJOR=20
REQUIRED_NODE_MINOR=19

# 如果安装了 fnm，自动加载
if command -v fnm &> /dev/null; then
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env --use-on-cd)"
fi

# 检查 Node.js 版本
echo -e "${YELLOW}[1/4] 检查 Node.js 环境...${NC}"
if ! command -v node &> /dev/null; then
    echo -e "${RED}错误: 未找到 Node.js，请先运行 ${YELLOW}./setup.sh${RED} 安装环境${NC}"
    exit 1
fi

NODE_VERSION=$(node -v)
NODE_VERSION_NUM=${NODE_VERSION#v}
IFS='.' read -r NODE_MAJOR NODE_MINOR NODE_PATCH <<< "$NODE_VERSION_NUM"

echo -e "${GREEN}当前 Node.js 版本: $NODE_VERSION${NC}"

# 检查版本是否满足要求
if [ "$NODE_MAJOR" -lt "$REQUIRED_NODE_MAJOR" ] || { [ "$NODE_MAJOR" -eq "$REQUIRED_NODE_MAJOR" ] && [ "$NODE_MINOR" -lt "$REQUIRED_NODE_MINOR" ]; }; then
    echo -e "${RED}错误: Node.js 版本过低，需要 $REQUIRED_NODE_MAJOR.$REQUIRED_NODE_MINOR+${NC}"
    echo -e "${YELLOW}请运行 ${YELLOW}./setup.sh${NC} 来升级 Node.js${NC}"
    exit 1
else
    echo -e "${GREEN}✓ Node.js 版本满足要求${NC}"
fi
echo ""

# 检查 pnpm 是否安装
echo -e "${YELLOW}[2/4] 检查 pnpm 环境...${NC}"
if ! command -v pnpm &> /dev/null; then
    echo -e "${RED}错误: 未找到 pnpm，请先运行 ${YELLOW}./setup.sh${RED} 安装环境${NC}"
    exit 1
fi

PNPM_VERSION=$(pnpm -v)
echo -e "${GREEN}✓ pnpm 版本: $PNPM_VERSION${NC}"
echo ""

# 检查依赖是否已安装
echo -e "${YELLOW}[3/4] 检查项目依赖...${NC}"
if [ ! -d "node_modules" ]; then
    echo "node_modules 不存在，正在安装依赖..."
    pnpm install
else
    echo -e "${GREEN}✓ 依赖已安装${NC}"
fi
echo ""

# 检查 .env 文件
echo -e "${YELLOW}[4/4] 检查配置文件...${NC}"
if [ ! -f ".env" ] && [ -f ".env.example" ]; then
    echo "未找到 .env 文件，正在从 .env.example 复制..."
    cp .env.example .env
    echo -e "${GREEN}✓ 已创建 .env 文件${NC}"
elif [ -f ".env" ]; then
    echo -e "${GREEN}✓ .env 文件已存在${NC}"
else
    echo -e "${YELLOW}⚠ 未找到 .env.example 文件${NC}"
fi
echo ""

# 启动开发服务器
echo "=========================================="
echo -e "${GREEN}正在启动开发服务器...${NC}"
echo "=========================================="
echo ""
echo "项目将在 http://localhost:5173 上运行"
echo "按 Ctrl+C 停止服务器"
echo ""

# 启动开发服务器
pnpm dev
