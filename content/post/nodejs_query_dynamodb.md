---
title: "DynamoDBのデータをLambdaでクエリする方法(AWS SDK for JS3がバンドルされているNode.jsを使用)"
date: 2023-12-03T20:29:01+09:00
#draft: true
share_img: img/node.png
categories: AWS
description: DynamoDBのデータをLambdaでクエリする方法を解説します
---

こんにちは。  
この記事は[TechCommit Advent Calendar 2023](https://adventar.org/calendars/8839) 3日目の記事です。  
<br>

[別記事](https://amybunny.work/post/dynamodb/)ではPartiQLを使用してDynamoDBのデータをクエリする方法を紹介しましたが、本記事ではLambda(Node.js)でクエリする方法を解説します。  
<br>

※本記事では、DynamoDBとは何ぞや？については触れません。  
初心者の方は、[Amazon DynamoDBとは何かをわかりやすく図解、どう使う？テーブル設計の方法とは](https://www.sbbit.jp/article/cont1/95515)などを読んでみるとよいと思います。

### 方法
前回と同じデータを例に説明します。
{{< figure src="/img/dynamo/dynamo.png" >}}

コードは以下の通りです。
{{< highlight javascript "linenos=true" >}}
//必要なライブラリをインポート
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { QueryCommand, DynamoDBDocumentClient } from "@aws-sdk/lib-dynamodb";

//Dynamoオブジェクトを生成
const client = new DynamoDBClient();
const docClient = DynamoDBDocumentClient.from(client);

export const handler = async () => {

  try{

    //クエリを作成
    const queryCommand = new QueryCommand({

      //テーブル名を指定
      TableName: "test",
      
      //検索値
      ExpressionAttributeValues:{
        ":prefecture":"東京都",
        ":age":30,
        ":date":"2023-01"
      },

      //検索条件(パーティションキーとソートキー)
      KeyConditionExpression:
        "prefecture = :prefecture AND age > :age",
      
      //検索条件(上記以外のカラム)
      FilterExpression:
        "begins_with(#date,:date)",
      
      //検索条件にDynamoDBの予約語が入っている場合の処理
      ExpressionAttributeNames:{
        "#date":"date"
      },
      
    });

    //クエリを実行
    const response = await client.send(command);

  }catch(e){
    console.log("エラー：" + e);
  }
  
};
{{< / highlight >}}

上記のコードを実行すると、以下のjsonが返ってきます。
{{< highlight javascript "linenos=true" >}}
    {
      prefecture: '東京都',
      username: '鈴木',
      date: '2023-01-01 11:23:33',
      age: 31
    },
    {
      prefecture: '東京都',
      username: '芦田',
      date: '2023-01-24 14:56:34',
      age: 40
    },
    {
      prefecture: '東京都',
      username: '谷本',
      date: '2023-01-11 11:23:33',
      age: 41
    }
{{< / highlight >}}

### コードの解説

**KeyConditionExpression**と**FilterExpression**が、SQLでいうwhere句にあたります。  
Keyの方ではパーティションキー(必須)とソートキー(任意)を指定します。   
Filterの方は、パーティションキーとソートキー以外のカラムを検索に使いたい時に使用します。  
<br>
検索条件は、```prefecture = "東京都"```のように直接指定せず、プレースホルダを使用します。  
```prefecture = :prefecture```としておき、**ExpressionAttributeValues**で```":prefecture":"東京都"```とします。  
<br>
検索に使いたいカラム名がDynamoDBの予約語だった場合、検索条件の中で直接指定することができません。今回の場合、「date」の部分が該当します。  
<br>
通常であれば```begins_with(date,:date)```で良いのですが、これではエラーになります。  
そのため、検索条件内では#を付けて```begins_with(#date,:date)```とし、  
**ExpressionAttributeNames**の中で```"#date":"date"```のようにカラムを指定します。  

### おわりに
なんたらExpression、なんたらAttributeがたくさん出てきて最初は大変ですが、最小構成から少しずつ試すと分かってくると思います。  
<br>
誰かの参考になれば幸いです。  
<br>

### 参考
[JavaScript (v3) 用の SDK を使用した DynamoDB の例](https://docs.aws.amazon.com/ja_jp/sdk-for-javascript/v3/developer-guide/javascript_dynamodb_code_examples.html)  
[QueryCommand](https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/client/dynamodb/command/QueryCommand/)  
[Filter expressions for the Query operation](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Query.FilterExpression.html)