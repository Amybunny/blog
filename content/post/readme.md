---
title: "Readme"
date: 2023-11-23T16:23:31+09:00
draft: true
share_img: img/share_img.png
categories: 
description:
---

### 新しい記事を作る  
　$ hugo new post/hoge.md  
<br>

### ローカルサーバーを立ち上げる  
　$ hugo server -D  
<br>

### デプロイする  
　$ sh deploy.sh  
<br>

### Tips
・blogフォルダが下書き  
・hugoコマンドでpublic配下にhtmlなどが作成される  
・public配下をgithubのAmybunny.github.ioにデプロイしている  
<br>

### コードを書く
{{< highlight html "linenos=true" >}}
<html>
  <body>
    <p>ほげ</p>
  </body>
</html>
{{< / highlight >}}

### imageを載せる
{{< figure src="/img/share_img.png" >}}

### 引用する
>これは引用です  
>これは引用です