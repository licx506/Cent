#!/bin/bash

# Cent 项目环境搭建脚本
# 用于在 Linux 系统上配置项目运行环境

set -e  # 遇到错误立即退出

echo "=========================================="
echo "       Cent 项目环境搭建脚本"
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

# 版本比较函数
version_ge() {
    [ "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1" ];
}

# 检查并安装 Node.js
echo -e "${YELLOW}[1/5] 检查 Node.js 环境...${NC}"
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}Node.js 未安装，正在安装...${NC}"
    curl -fsSL https://fnm.vercel.app/install | bash
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env --use-on-cd)"
    fnm install 22
    fnm use 22
    fnm default 22
else
    NODE_VERSION=$(node -v)
    NODE_VERSION_NUM=${NODE_VERSION#v}
    IFS='.' read -r NODE_MAJOR NODE_MINOR NODE_PATCH <<< "$NODE_VERSION_NUM"
    
    echo -e "${GREEN}当前 Node.js 版本: $NODE_VERSION${NC}"
    
    # 检查版本是否满足要求
    if [ "$NODE_MAJOR" -lt "$REQUIRED_NODE_MAJOR" ] || { [ "$NODE_MAJOR" -eq "$REQUIRED_NODE_MAJOR" ] && [ "$NODE_MINOR" -lt "$REQUIRED_NODE_MINOR" ]; }; then
        echo -e "${YELLOW}Node.js 版本过低，需要 $REQUIRED_NODE_MAJOR.$REQUIRED_NODE_MINOR+${NC}"
        echo -e "${YELLOW}正在使用 fnm 安装 Node.js 22...${NC}"
        
        # 检查 fnm 是否安装
        if ! command -v fnm &> /dev/null; then
            curl -fsSL https://fnm.vercel.app/install | bash
        fi
        
        export PATH="$HOME/.local/share/fnm:$PATH"
        eval "$(fnm env --use-on-cd)"
        fnm install 22
        fnm use 22
        fnm default 22
        
        NODE_VERSION=$(node -v)
        echo -e "${GREEN}✓ Node.js 已升级到: $NODE_VERSION${NC}"
    else
        echo -e "${GREEN}✓ Node.js 版本满足要求${NC}"
    fi
fi
echo ""

# 检查 npm
echo -e "${YELLOW}[2/5] 检查 npm 环境...${NC}"
if ! command -v npm &> /dev/null; then
    echo -e "${RED}错误: 未找到 npm${NC}"
    exit 1
fi

NPM_VERSION=$(npm -v)
echo -e "${GREEN}✓ npm 版本: $NPM_VERSION${NC}"
echo ""

# 安装 pnpm
echo -e "${YELLOW}[3/5] 检查并安装 pnpm...${NC}"
if ! command -v pnpm &> /dev/null; then
    echo "pnpm 未安装，正在安装..."
    npm install -g pnpm
    echo -e "${GREEN}✓ pnpm 安装成功${NC}"
else
    PNPM_VERSION=$(pnpm -v)
    echo -e "${GREEN}✓ pnpm 已安装，版本: $PNPM_VERSION${NC}"
fi
echo ""

# 清理旧的 node_modules（因为 Node.js 版本变化了）
echo -e "${YELLOW}[4/5] 清理旧依赖...${NC}"
if [ -d "node_modules" ]; then
    echo "检测到 Node.js 版本变化，正在清理旧的 node_modules..."
    rm -rf node_modules pnpm-lock.yaml
    echo -e "${GREEN}✓ 已清理旧依赖${NC}"
else
    echo -e "${GREEN}✓ 无需清理${NC}"
fi
echo ""

# 安装项目依赖
echo -e "${YELLOW}[5/5] 安装项目依赖...${NC}"
# 恢复 pnpm-lock.yaml（如果被删除了）
if [ ! -f "pnpm-lock.yaml" ] && [ -f ".git/pnpm-lock.yaml" ]; then
    git checkout pnpm-lock.yaml
fi

if [ -f "pnpm-lock.yaml" ]; then
    echo "使用 pnpm 安装依赖..."
    pnpm install
else
    echo -e "${RED}错误: 未找到 pnpm-lock.yaml 文件${NC}"
    exit 1
fi

echo ""
echo "=========================================="
echo -e "${GREEN}✓ 环境搭建完成！${NC}"
echo "=========================================="
echo ""
echo "接下来可以运行以下命令启动项目："
echo -e "  ${YELLOW}./start.sh${NC}  或  ${YELLOW}pnpm dev${NC}"
echo ""
echo "注意：如果是第一次使用 fnm，请重新加载终端配置或运行："
echo -e "  ${YELLOW}source ~/.bashrc${NC}"
echo ""
