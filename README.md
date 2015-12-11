# Custom Metrix

## 概要

標準では提供されていない統計データを登録して取得できるようにする。

## 使い方

```
git clone https://github.com/yoshiokaCB/custom_metrics.git
cd custom_metrix/
sudo cp credential.sample credential
sudo chown ec2-user. credential
chmod 600 credential
chmod 755 *.sh
```

cloudwatch用のユーザを取得して、`~/custom_metrix/credential` を編集する。

監視したいurlを `~/custom_metrix/domain_list.txt` に記述する。

```
crontab -e

*/5 * * * * ec2-user /home/ec2-user/cloudwatch/custom_metrics.sh
```
