---
title: "PHPやJavaでAjaxを実装する方法"
date: 2021-04-28
## draft: true
categories: JavaScript
share_img: "img/ajax.png"
description: Ajax通信の実装方法について説明します。
---
<br>
今回は、Ajax通信の基本的な実装方法について説明します。  
<br>
<br>
自作アプリにAjax通信を使いたくて検索しても、「Ajaxとは」について一生懸命説明していたり、余計なコードがあってどれが必要な記述なのか分からなかったりして苦労しました。  
<br>
<br>
この記事では記述の簡単なjQueryを用いて必要最低限のコードを示すことで、Ajaxを実装できるようにします。  
サンプルコードではPHPを使い、ユーザーが入力した言葉を画面に表示する処理を例に説明していきます。

## 普通のPOST送信だと
Ajaxにするとデータのやりとりがどう変わるのかを比較するために、まずは普通のPOST送信の記述例を示します。手っ取り早くAjaxのコードを見たい方は飛ばしてください。
<br>
<br>
index.php  
{{< highlight html "linenos=table" >}}
<?php 
  session_start();
?>
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <title>普通のPOST送信だよ</title>
</head>
<body>
  <form action="logic.php" method="post">
    <input type="text" name="words">
    <input type="submit" value="送信">
  </form>
  <p><?php if(!empty($_SESSION['words'])) echo $_SESSION['words']; ?></p>
</body>
</html>
{{< /highlight >}}
（PHPのコードがなぜかコメント扱いされていますが、必要なので記述してください。）
<br>
<br>
logic.php
{{< highlight php "linenos=table" >}}
<?php 
if(!empty($_POST)){
  session_start();
  $_SESSION['words'] = $_POST['words'];
}
header("Location:index.php");
{{< /highlight >}}
<br>
普通だと、  
<br>
　1.formタグのaction属性でデータの送信先(logic.php)を指定<br>
　2.POST送信された値を送信先で受け取る<br>
　3.セッションにデータを保存<br>
　4.元のページ(index.php)で、セッションからデータを取り出して表示    
<br>
などといった流れになるかと思います。その際、ページ全体を更新するので、画面が一度白くなります。  
{{< figure src="/img/input.png" >}}
{{< figure src="/img/display.png" >}}

## Ajaxだと
今度はAjaxを使うとどのような流れになるかを見ていきます。  
<br>
index.php
{{< highlight html "linenos=table" >}}
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <script src="https://code.jquery.com/jquery-3.4.1.min.js"></script>
  <title>Ajaxだよ</title>
</head>
<body>
  <input type="text" id="words">
  <button id="send">送信</button>
  <p id="display"></p>
  <script>
    $(function(){
      $('##send').on('click',function(){

        //送信するデータを変数に入れる
        let words = $('##words').val();

        //1.通信に必要な情報
        $.ajax({
          type:"POST", //POST送信であること
          url:"logic.php", //送信先のファイル
          data:{"words":words}, //送信するデータ
          dataType:"json" //データの形式。jsonが多い。

        //2.通信が成功した時の処理
        }).done(function(result){
          $('##display').html(result);

        //3.通信が失敗した時の処理
        }).fail(function(){
          alert("読み込み失敗");
        })
      })
    })
  </script>
</body>
</html>
{{< /highlight >}}
<br>
Ajax通信を使いたいときは、  
　1.通信に必要な情報  
　2.通信が成功した時の処理  
　3.通信が失敗した時の処理  
を書きます。
<br>
<br>
21行目は、引用符で囲んだ部分("words")がデータにつける名前(キー)で、コロンの右側(words)が15行目で変数に入れた実データです。送信先のファイルで、$_POST['words']といった形で取り出すことができます。
<br>
<br>

2.では、返ってきたデータがfunction()の引数に入るので、```<p id="display"></p>```の中身を、返ってきたデータに書き換える処理にしています。
<br>
<br>
ligic.php
{{< highlight php "linenos=table" >}}
<?php
  $words = $_POST['words'];
  header("Content-type: application/json; charset=UTF-8");
  echo json_encode($words);
  exit;
{{< /highlight >}}
受け取る側のファイルでは、まず送信されてきた値を$wordsという変数に入れています。  
次に、header関数でデータタイプをjsonに指定します。  
そして、$wordsの値を```json_encode()```でjson形式に変換して送り返し、```exit;```で明示的にphpの処理を終えます。  
<br>
こうして、ページ全体を更新することなく、一部分をサクサクと書き換えることができるようになります。  
<br>
実際のアプリなどでは、送信先のファイルでデータベース処理を行うことが多いと思います。 
<br>
ex）  
・いいねボタンを押したらDBのいいねを増やし、画面の数字も増やす。  
・会員登録時に入力されたIDをDBから瞬時に検索し、使用可否を画面に表示する。  

## Javaだと  
JSP/サーブレットで作ったアプリにAjaxを使いたかったので、PHPで動いたコードを元にJavaでの書き方を模索しました。  
<br>
いいねボタンを押したら送信先でいいねを増やす処理をして、返ってきた数字を画面に表示させるコードです。 
<br> 
main.jsp
{{< highlight html "linenos=table" >}}
<script>
  $(function(){
    $('.likebtn').on('click',function(){
      let likebtn = $(".likebtn").val();
      $.ajax({
        type:"GET",
        url:"Main", //「.java」はいらない
        data:{likebtn:likebtn} //キーに引用符はいらない
      }).done(function(result){
        $(".ev").html(result);
      }).fail(function(){
        alert("読み込み失敗");
      })
    })
  })
</script>
{{< /highlight >}}
送信先のコードは長いので、見たい方は[github](https://github.com/Amybunny/mugenlikes/blob/main/src/main/java/servlet/Main.java)を見てください。
Ajaxを使わない場合はフォワードで元のページに戻ってきましたが、PHPの```echo()```のように、```out.print()```にいいね数を入れることでデータが返ってきます。  
<br>
こうしてできたのが[無限いいね](https://mugenlikes.herokuapp.com/)です。  

## まとめ
最初はなんとなくとっつきにくいAjaxですが、  
<br>
・データのやりとりをJavaScriptがやってくれること  
・やりとりするデータの形式はjsonが多いこと    
<br>
がつかめれば、使いこなせるようになると思います。  
ぜひ使ってみてください！