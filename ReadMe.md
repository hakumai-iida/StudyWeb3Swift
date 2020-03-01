## はじめに  
ややこしい話は抜きにして、**iOS** で **Ethereum** ブロックチェーンへアクセスしてみるサンプルです。  

下記の **web3swift** ライブラリを利用させていただいております。  
<https://github.com/matter-labs/web3swift>    

----
## 手順  
### ・**CocoaPods** の準備
　ターミナルを開き下記のコマンドを実行します  
　`$ sudo gem install cocoapods`  

### ・**web3swift** のインストール
　ターミナル上で **StudyWeb3Swift** フォルダ(※ **Podfile** のある階層)へ移動し、下記のコマンドを実行します  
　`$ pod install`  
　
### ・ワークスペースのビルド
　**StudyWeb3Swift.xcworkspace** を **Xcode** で開いてビルドします  
　（※間違えて **StudyWeb3Swift.xcodeproj** のほうを開いてビルドするとエラーになるのでご注意ください）
　
### ・動作確認
　**Xcode** から **iOS** 端末にてアプリを起動し、画面をタップするとテストが実行されます  
　**Xcode** のデバッグログに下記のようなログが表示されるのでソースコードと照らし合わせてご確認下さい
　
> @--------------------------  
> @ TestWeb3: start...  
> @--------------------------  
> @------------------  
> @ setTarget  
> @------------------  
> @ target: rinkeby  
> @------------------  
> @ setKeystore  
> @------------------  
> @ loadKeystoreJson: json= {"version":3,"id":"ebb74846-ab37-4da8-a3db-74c3edd5e4c3","crypto":{"ciphertext":"22489751acd45de1dbba65cdc4660c84835f245f5a6e3974412ea1b26a094655","cipherparams":{"iv":"8c30430c5286a61bfb96f746f2169a38"},"kdf":"scrypt","kdfparams":{"r":6,"p":1,"n":4096,"dklen":32,"salt":"b2f8675406040fad418db1ab77b8c9e0b4a4c143e37c2ab9840bdbc54cd1be98"},"mac":"d89db9e4a943cf207dd96feb05ea9f95218f8d450e409caf882d2d2c85ac6b92","cipher":"aes-128-ctr"},"address":"0x69a8750b21bef61b3a91d5e4f529c05daacff242"}  
> @ loadKeystore: result= true  
> @ CURRENT KEYSTORE  
> @ ethreumAddress: 0x69A8750B21BEf61B3A91D5e4F529C05dAacFf242  
> @------------------  
> @ checkBalance  
> @------------------  
> @ balance: 189939900000000000 wei  
> @------------------  
> @ checkSend  
> @------------------  
> @ try writeTx.sendPromise().wait()  
> @ result: TransactionSendingResult(transaction: Transaction  
> Nonce: 2  
> Gas price: 1000000000  
> Gas limit: 21000  
> To: 0xebfCB28c530a9aAD2e5819d873EB5Cc7b215d1E1  
> Value: 10000000000000000  
> Data: 0x  
> v: 44  
> r: 95571037867526195042673269001797257457223374469362157136743945720005968409145  
> s: 33775738110425176826016162502146871759787215705215444062253304629307649199382  
> Intrinsic chainID: Optional(4)  
> Infered chainID: Optional(4)  
> sender: Optional("0x69A8750B21BEf61B3A91D5e4F529C05dAacFf242")  
> hash: Optional("0x5a1b53d8be178ad1611d787fd5aaf26105eef7ba9e604b074206b413eb600e09")  
> , hash: "0x5a1b53d8be178ad1611d787fd5aaf26105eef7ba9e604b074206b413eb600e09")  
> @------------------  
> @ checkHelloWorld  
> @------------------  
> @ [HelloWorld].getWord: Greeting from web3swift at Mar 1, 2020 17:50:22  
> @ [HelloWorld].sendWord: Greeting from web3swift at Mar 1, 2020 17:51:30  
> @ tx: TransactionSendingResult(transaction: Transaction  
> Nonce: 3  
> Gas price: 1000000000  
> Gas limit: 30700  
> To: 0xd21CE6F369F8281B7D39B47372c8F4A8A77841fc  
> Value: 0  
> Data: 0xcd048de60000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000002f4772656574696e672066726f6d20776562337377696674206174204d617220312c20323032302031373a35313a33300000000000000000000000000000000000  
> v: 43  
> r: 60176129726031645750356914469654960536820967718745200895239281252040467695680  
> s: 1181748530259540773955497782179266619818312553637259529090920947413751811780  
> Intrinsic chainID: Optional(4)  
> Infered chainID: Optional(4)  
> sender: Optional("0x69A8750B21BEf61B3A91D5e4F529C05dAacFf242")  
> hash: Optional("0x8bc6495612f7f081cff1532b27a70ff7d69cad67adaa871679f5f0e36960c603")  
> , hash: "0x8bc6495612f7f081cff1532b27a70ff7d69cad67adaa871679f5f0e36960c603")  
> @--------------------------  
> @ TestWeb3: finished  
> @--------------------------  

----
## 補足

テスト用のコードが **TestWeb3.swift**、簡易ヘルパーが **Web3Helper.swift**、 イーサリアム上のコントラクトに対応するコードが **ContractHelloWorld.swift**となります。  

その他のソースファイルは **Xcode** の **Game** テンプレートが吐き出したコードそのまんまとなります。ただし、画面タップでテストを呼び出すためのコードが **GameScene.swift** に２行だけ追加してあります。

**sol/HelloWorld.sol** はテストアプリがアクセスするコントラクトのソースとなります。**Xcode** では利用していません。

テストが開始すると、デフォルトで **Rinkeby** テストネットへ接続します。  

初回の呼び出し時であればアカウントを作成し、その内容をアプリのドキュメント領域に **key.json** の名前で出力します。二度目以降の呼び出し時は **key.json** からアカウント情報を読み込んで利用します。  

**ETH** の送金テスト、コントラクトへの書き込みテストは、対象のアカウントに十分な残高がないとエラーとなります。**Xcode** のログにアカウント情報が表示されるので、適宜、対象のアカウントに送金してテストしてください。
  
----
## メモ
　2020年3月1日の時点で、下記の環境で動作確認を行なっています。  

#### 実装環境
　・**macOS Mojave 10.14.4**  
　・**Xcode 11.3.1(11C504)**

#### 確認端末
　・**iPhone X** **iOS 11.2**  
　・**iPhone 7 plus** **iOS 13.3.1**  
　・**iPhone 6 plus** **iOS 10.3.3**  
　・**iPhone 6** **iOS 11.2.6**  
　・**iPhone 5 s** **iOS 10.2**  
　・**iPad**(第六世代) **iOS 12.2**  
