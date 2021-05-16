---
title: "JSP&サーブレットで作ったアプリをherokuにデプロイする方法"
date: 2021-04-23
# draft: true
categories: Java
share_img: "img/JavaMaven/jsp.png"
description: ある日、Eclipceを使ってサーブレット＆JSPで簡単なアプリを作りました。せっかくだから公開したいと思い、herokuでデプロイすることにしましたが、ここがどうやら鬼門のようで、ググって出てくる他の初心者のみなさんと同様に、とんでもなくハマりました(約30時間)。
---

# はじめに
ある日、Eclipceを使ってサーブレット＆JSPで簡単なアプリを作りました。
せっかくだから公開したいと思い、herokuでデプロイすることにしましたが、ここがどうやら鬼門のようで、ググって出てくる他の初心者のみなさんと同様に、とんでもなくハマりました(約30時間)。  
<br>
「絶対にデプロイできる方法(¥5,000)」みたいなnoteもあってなんかムカついたので、絶対自力で成功してやる！！！そしてやり方を無料で公開してやる！と決意し、無事成功したので、ここに書き残します。私の屍を超えてください。

## 当時の筆者の状況
・Java歴2ヶ月  
・ターミナル操作は多少できる  
・GitHubはブラウザからのアップロードならできる（ターミナルからのコマンド操作はできない）  

## 心構え
Javaで作ったアプリをherokuにデプロイする際は、**Maven**を導入し、正しく設定する必要があります。  
<br>
Mavenはビルド自動化ツールといって、必要なプラグインやゴールを**pom.xml**というファイルに書いておけば、コンパイルやテストの実行、JARファイルの作成など面倒なことを一気にやってくれるものです。  
<br>
このMavenが1番のつまづきポイントだったので、初心者の方はここを乗り越えるのをがんばってください。  

## この記事で説明しないこと
・GitHubの使い方  
・herokuアカウントの作り方  
・ターミナルの使い方  
<br>
※herokuへのデプロイ方法はいくつかありますが、この記事ではGitHub連携を使用します。

# 目次
1.Mavenをインストール  
2.環境変数の設定  
3.Eclipseの設定  
4.Mavenプロジェクトへの変換  
5.herokuでの作業  
<br>
早速始めましょう！

# 1.Mavenをインストール
まずはMavenをインストールします。やり方は、  
・**brewインストール**   
・**公式サイトからダウンロード**  
の２種類あります。お好きな方を選んでください。  

## brewインストール
（Homebrewがインストールされている必要があります。）  
ターミナルで以下のコマンドを実行します。  
```txt
 $ brew install maven
```
<br>

## 公式サイトからダウンロード
[こちらのサイト](https://maven.apache.org/download.cgi)からダウンロードします。「Binary zip archive」を選びます。  
{{< figure src="/img/JavaMaven/download.png" >}}  
ファイルを解凍したら、windowsであればC:/、macであれば/usr/local/など好きな場所に移動します。  

# 2.環境変数の設定
Mavenのバージョンはご自身がダウンロードしたものに合わせてください。  <br>

## Windows10の場合
1.スタートボタン ＞ Windowsシステムツール ＞ コントロールパネル ＞ システムとセキュリティ ＞ システム ＞ システムの詳細設定 ＞ 詳細設定 ＞ 環境変数 を順にクリック  
<br>
2.「システム環境変数(S)」の「Path」を選択し、「新規(W)」ボタンをクリック  
<br>
3.「C:\apache-maven-3.8.1\bin」を追加する  
<br>

## macの場合  
ログインシェルがbashなら  
```txt
 open ~/.bash_profile
```
zshなら
```txt
 open ~/.zprofile
```
で設定ファイルを開き、
```txt
 export PATH=/usr/local/apache-maven-3.8.1/bin:$PATH 
```
を追加します。  
<br>
ログインシェルがわからない場合は、
```txt
 echo $SHELL
```
で調べられます。  
<br>
brewインストールした場合はファイルの配置場所が/Libralyなどになっているかと思うので、/usr/local/の部分を/Libraly/に変えてください。  
<br>
追加できたら、以下のコマンドで設定を反映させます。
```txt
 source ~/.bash_profile
 または
 source ~/.zprofile
```
<br>

## 正常にインストールできたか確認  
コマンドプロンプトやターミナルで、以下のコマンドを入力します。
```txt
 mvn --version
```
<br>```Apache Maven 3.8.1```などのように、バージョンが表示されればインストール完了です。

# 3.Eclipseの設定
Mavenがインストールできたら、EclipseでMavenが使えるように設定をする必要があります。  
## Mavenプラグインのインストール  
Eclipse2019-9以降を使っている場合、プラグインは最初から入っているのでインストール不要です。  
<br>
それ以前の場合は、ヘルプ ＞ 「Eclipseマーケットプレース」をクリック ＞ 「m2e」で検索 ＞ 「Eclipse用 Maven 統合(Luna and newer)1.5」をインストールします。
{{< figure src="/img/JavaMaven/marketplace.png" >}}
インストールできたら、Eclipseを再起動します。  
<br>

## Mavenプラグインの設定
次に、Mavenプラグインの設定をします。  
設定 ＞ Maven ＞ ユーザー設定を開き、ユーザー設定の所に以下のパスを入力します。  
```/usr/local/maven/conf/settings.xml```
{{< figure src="/img/JavaMaven/mavensetting.png" >}}
※ここも、Mavenの配置場所に応じてパスを変えてください。私は/Library/にしています。

# 4.Mavenプロジェクトへの変換
Mavenプラグインの設定ができたら、動的webプロジェクトとして作ったアプリを**Mavenプロジェクト**に変換する必要があります。やることは以下7つです。
<br>  
1.新規Mavenプロジェクト作成  
2.フォルダ作成・設定変更  
3.ファイルのコピー  
4.pom.xmlの記述  
5.Procfileの作成  
6.ビルド  
7.GitHubへのアップロード  
<br>
順番に見ていきましょう。  
<br>

## 4-1.新規Mavenプロジェクト作成
ファイル ＞ 新規作成 ＞ Mavenプロジェクト ＞ 次へをクリック
{{< figure src="/img/JavaMaven/newmaven.png" >}}  
<br>
<br>
アーキタイプは「maven-archetype-webapp」を選択
{{< figure src="/img/JavaMaven/archetype.png" >}}  
<br>
<br>
グループidとアーティファクトidを決めて、「完了」をクリック
{{< figure src="/img/JavaMaven/parameter.png" >}}  
<br>

## 4-2.フォルダ作成・設定変更
次に、フォルダ作成・各種設定変更をします。  
<br>
srcフォルダの中に、以下のような階層で新しいフォルダを作ります。  
mainフォルダだけは自動で作成されているので、その中にjavaフォルダを作り、test/javaフォルダは新しく作ってください。
```txt
 src
 ├─main─java
 ├─test─java
```  
<br>
<br>
作成したプロジェクト名を右クリック ＞ プロパティ ＞ Javaのビルド・パス ＞ JREシステムライブラリーを選択し、右側の「編集」をクリック
{{< figure src="/img/JavaMaven/property.png" >}}  
<br>
<br>
実行環境をJava8に変更し、完了をクリック  
{{< figure src="/img/JavaMaven/8.png" >}}  
<br>
<br>
先ほどのプロパティ画面右側の「ライブラリーの追加」をクリック  
サーバー・ランタイムを選択し、次へをクリック
{{< figure src="/img/JavaMaven/server.png" >}}  
<br>
<br>
Tomcat8を選択(Tomcat9でも可)、完了をクリック
{{< figure src="/img/JavaMaven/server-choice.png" >}} 
<br> 

## 4-3.ファイルのコピー  
元の動的webプロジェクトから、新しいMavenプロジェクトにファイルをコピーします。  
<br>
Javaリソース/src以下のパッケージやファイルを、Javaリソース/src/main/java以下にコピー  
{{< figure src="/img/JavaMaven/package2.png" >}}  
WebContent/WEB-INF以下のファイルを、src/main/webapp/WEB-INF以下にコピー  
{{< figure src="/img/JavaMaven/webinf2.png" >}}  
<br>

## 4-4.pom.xmlの記述  
次に、Mavenの設定ファイルであるpom.xmlに記述を追加していきます。  
<br>
&lt;dependencies&gt;に以下を追加
{{< highlight xml "linenos=table">}}
<dependency>
	<groupId>javax.servlet</groupId>
	<artifactId>javax.servlet-api</artifactId>
	<version>3.1.0</version>
</dependency>
{{</highlight>}}  
    
<br>&lt;plugins&gt;に以下を追加   
{{< highlight xml "linenos=table">}}
<plugin>
	<groupId>org.apache.maven.plugins</groupId>
	<artifactId>maven-dependency-plugin</artifactId>
	<executions>
		<execution>
			<phase>package</phase>
			<goals><goal>copy</goal></goals>
			<configuration>
				<artifactItems>
					<artifactItem>
						<groupId>com.heroku</groupId>
						<artifactId>webapp-runner</artifactId>
						<version>9.0.41.0</version>
						<destFileName>webapp-runner.jar</destFileName>
					</artifactItem>
				</artifactItems>
			</configuration>
		</execution>
	</executions>
</plugin>
{{</highlight>}}  
<br>
※もし&lt;plugins&gt;の親要素に&lt;pluginManagement&gt;タグがあったら削除してください。これがあるとherokuがwebapp-runner.jarを認識できないようで、謎のエラーに悩まされました。  
<br>
<br>

## 4-5.Procfileの作成  
プロジェクトのルートディレクトリにProcfileという名前のファイルを作成し、以下の1行を記述する。  
```txt
 web: java $JAVA_OPTS -jar target/dependency/webapp-runner.jar --port $PORT target/*.war
```  
<br>


※必ず**ルートディレクトリ**に配置するのと、ファイル名の頭文字は**大文字**にしてください。そうしないと、herokuに認識されずエラーになります。  


<br>
<br>

## 4-6.ビルド  
pom.xmlを右クリック ＞ 実行 ＞ Mavenビルドを選択し、ゴールを「clean install」にし、「テストのスキップ」にチェックを入れ、ビルドを実行  
{{< figure src="/img/JavaMaven/build.png" >}}  

BUILD SUCCESSが表示されればOKです。
{{< figure src="/img/JavaMaven/buildsuccess.png" >}}<br>

## 4-7.GitHubへのアップロード
ビルドが終わったら、できたソースコードをGitHubにアップロードしておいてください。

# 5.herokuでの作業  
Mavenビルドができたら、今度はheroku側での作業に移ります。herokuアカウントはあらかじめ作成しておいてください。やることは以下4つです。
<br>  
1.アプリの作成  
2.ビルドパックの設定  
3.GitHub連携  
4.デプロイ  
<br>

## 5-1.アプリの作成  
Personalページ右上の「New」 ＞ 「Create new app」を選択  
{{< figure src="/img/JavaMaven/create-new-app.png" >}}  
<br>
アプリ名を決めて、「Create app」をクリック  
(great-appは使えないと言われたのでthe-great-appにしました。)  
{{< figure src="/img/JavaMaven/app-name.png" >}}  

## 5-2.ビルドパックの設定
アプリページのメニューから「Settings」を選択  
{{< figure src="/img/JavaMaven/settings.png" >}}  
<br>
「Add buildpack」をクリック  
{{< figure src="/img/JavaMaven/add-buildpack.png" >}}  
<br>
javaを選択し、「Save changes」をクリック  
{{< figure src="/img/JavaMaven/buildpack.png" >}}  
<br>

## 5-3.GitHubと連携する
アプリページのメニューから「Deploy」を選択し、「GitHub」ボタンをクリック  
{{< figure src="/img/JavaMaven/deploy.png" >}}  
<br>
作ったアプリが保存されているリポジトリ名を入力し、「Search」ボタンをクリック  
{{< figure src="/img/JavaMaven/github.png" >}}  
<br>
該当のリポジトリ名が表示されるので、「Connect」をクリック
{{< figure src="/img/JavaMaven/search-github.png" >}}  
<br>
無事連携されると、GitHubボタンに「Connected」と表示されます。  
{{< figure src="/img/JavaMaven/connected.png" >}}  

## 5-4.デプロイする
GitHub連携すると、Deployページの一番下に「Deploy Branch」というボタンが表示されるので、それをクリック  
{{< figure src="/img/JavaMaven/deploy-branch.png" >}}  
<br>
無事デプロイできたら、以下のように「Your app was successfully deployed.」と表示され、「View」ボタンをクリックすると、アプリが見られます。  
{{< figure src="/img/JavaMaven/success.png" >}}  
<br>
※herokuにデプロイすると、アプリのURLが変わってしまうことに注意してください。例えば、ローカルでリダイレクトURLを「/great-app/index.jsp」にしていた場合、herokuでは「/index.jsp」にしないと正常に動きません。  
<br>
これは、ローカルだと「localhost:8080」を起点としていたのに対し、herokuでは「great-app」が起点となるからだと思います。これも結構ハマったポイントでした。  

# おわりに
こうしてできたのが[無限いいね](https://mugenlikes.herokuapp.com/)です。長い戦いでした。  
<br>
<br>
<br>