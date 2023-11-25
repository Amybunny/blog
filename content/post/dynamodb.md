---
title: "PartiQLを使用してDynamoDBのデータをCSVに出力する方法"
date: 2023-11-23T15:19:40+09:00
draft: true
share_img: "img/dynamo/partiql.png"
categories: aws
description: DynamoDBのデータをCSVに落とす方法を解説します。
---

こんにちは。  
DynamoDBのデータをCSVに落とす必要があったのですが、  
マネコンからだと300件ずつしか落とせず困っていました。  
<br>
ググっても痒い所に手が届かず試行錯誤しましたが、  
PartiQLを使用すると簡単にできたので紹介します。
<br>

### PartiQLとは
PartiQLはDynamoDBに対してSQLが使える機能です。  
あまり高度なことはできませんが、使い慣れたSQLでクエリできるので便利です。  

### やり方
以下のようなデータがあったとします。  
<br>
パーティションキー：prefecture  
ソートキー：age
{{< figure src="/img/dynamo/dynamo.png" >}}
<br>
この中から、東京都の30歳以上の人を抽出してみます。  
{{< highlight sql "linenos=true" >}}
SELECT * FROM test WHERE prefecture = '東京都' and age > 30
{{< / highlight >}}
<br>
すると、以下のように結果が返ってきます。  
右上の「結果をCSVにダウンロードする」ボタンを押すと、  
結果が300件以上であっても、一括でDLすることができます。
{{< figure src="/img/dynamo/outcome.png" >}}
<br>
これを日付で絞り込みたければ、以下のように「begins_with」関数を使います。
{{< highlight sql "linenos=true" >}}
SELECT * FROM test WHERE prefecture = '東京都' and age > 30 and begins_with("date",'2023-01')
{{< / highlight >}}
<br>
絞り込みできました。
{{< figure src="/img/dynamo/begins_with.png" >}}

他にも、SIZE,EXISTS,ATTIBUTE_TYPE,CONTAINS,MISSINGなどの関数があります。  
[Amazon DynamoDB での PartiQL 関数の使用](https://docs.aws.amazon.com/ja_jp/amazondynamodb/latest/developerguide/ql-functions.html)  

### SQLの書き方
・カラム名は引用符不要。ただし、DynamoDBの予約語(dateなど)の場合はダブルクォーテーションで囲む。  
・検索値はシングルクォーテーションで囲む。

### 注意点
Where句でパーティションキーを使用して絞り込みをしないと、  DynamoDBに対してフルスキャンをかけてしまい、料金がかさむ場合があるようです。