# AzureCliSample1
Web用VM(CentOS)とAzure Database for MySQL構成のスクリプト

* conf.txtを作成
以下を設定すること
```:conf.txt
# 案件名
PJ_NAME

# リソースグループ名
RESOURCE_GROUP_NAME
# リージョン
LACATION

# NW関連
# VNet（仮想ネットワーク）名とネットワークアドレス
VNET_NAME
VNET_ADDRESS
# WEB用サブネット名とネットワークアドレス
SUBNET_NAME
SUBNET_ADDRESS
# 内部用サブネット名とネットワークアドレス
DB_SUBNET_NAME
DB_SUBNET_ADDRESS

# VM関連
# VMインスタンス名
VM_NAME
# パブリックIP名とDNSラベル名
PUBLICIP_NAME
DNS_LABEL
# NSG名
NSG_NAME
# 仮想NIC名
NIC_NAME
# 可用性セット
AVSET_NAME

# インスタンスタイプ
INSTANCE_SIZE
# OSイメージ
OS_IMAGE
# VM管理者アカウント
VM_ADMIN_NAME
# 公開鍵パス
PUB_KEY_PASS
# VMプライベートIP
VM_PRIVATEIP
# SSH接続元IP
SSH_OK_IP

# Azure DB MySQL関連
# DBインスタンス名
DBSERVER_NAME
# DB管理者アカウント
MYSQL_ADMIN_NAME
# DB名情報
PROD_DB
PRODDB_USER
PRODDB_PASS
TEST_DB
TESTDB_USER
TESTDB_PASS

# サーバ設定情報
# ホスト名
PROD_HOST
TEST_HOST=
# 開発者アカウント
DEVELOPER_NAME
# Basic認証情報
BASIC_AUTH_ID
BASIC_AUTH_PASS
```

* Azureログイン  
```:bash
az login
```

* サブスクリプション確認とサブスクリプション  
```:bash
az account list --output table
az account set --subscription [サブスクリプションID]
```

* 変数を修正した後、実行
```:bash
bash -x AzureVmDb.azcli
```