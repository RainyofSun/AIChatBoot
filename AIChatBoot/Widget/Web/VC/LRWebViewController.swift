//
//  LRLRWebViewController.swift
//  HSTranslation
//
//  Created by 苍蓝猛兽 on 2022/10/19.
//

import UIKit
import WebKit

class LRWebViewController: UIViewController {
    
    // Web链接
    open var webLinkUrl: String? {
        didSet {
            if let _url = webLinkUrl, let _webURL = URL.init(string: _url) {
                self.webView.load(URLRequest.init(url: _webURL))
            }
        }
    }
    
    // 额外信息
    open var webExtraInfo: Dictionary<String, Any>? {
        didSet {
            if let _extraInfo = webExtraInfo {
                if let _showT = _extraInfo["showTitle"] as? Bool {
                    self.showWebTitle = _showT
                }
                if let _hide = _extraInfo["hideCustomNav"] as? Bool {
                    self.customNavView.isHidden = _hide
                }
            }
        }
    }
    
    private lazy var webView: WKWebView = {
        let view = WKWebView(frame: CGRect.zero, configuration: addConfig())
        view.uiDelegate = self // UI代理
        view.navigationDelegate = self // 导航代理
        view.allowsBackForwardNavigationGestures = true // 允许左滑返回
        return view
    }()
    
    private lazy var progressView: UIProgressView = {
        let view = UIProgressView(frame: .zero)
        view.tintColor = UIColor.init(hexString: "#2A80FF")
        view.trackTintColor = UIColor.init(hexString: "#34CAF7")
        view.isHidden = true
        return view
    }()
    
    private lazy var activityView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.large)
        view.color = .white
        view.backgroundColor = UIColor(hexString: "#333333")
        view.cornerRadius = 10
        view.hidesWhenStopped = true
        return view
    }()
    
    private lazy var customNavView: LRWebCustomNavView = {
        let view = LRWebCustomNavView.init(frame: CGRect.zero)
        return view
    }()
    
    // 是否显示title
    private var showWebTitle: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        webView.scrollView.delegate = self
        self.view.addSubview(webView)
        self.view.addSubview(progressView)
        webView.addSubview(activityView)
        self.view.addSubview(customNavView)
        customNavView.navigationDelegate = self
        settingProgress()
        let _top: CGFloat = (self.navigationController?.navigationBar.bounds.height ?? 44) + UIApplication.shared.statusBarFrame.height
        customNavView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(_top)
        }
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        activityView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(100)
        }
        progressView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            if self.customNavView.isHidden {
                make.top.equalToSuperview()
            } else {
                make.top.equalTo(customNavView.snp.bottom)
            }
            make.height.equalTo(2)
        }
        if customNavView.isHidden {
            self.navigationController?.setNavigationBarHidden(!customNavView.isHidden, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    deinit {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "getJSFuncNoParams")
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "getJSFuncWithParams")
        webView.configuration.userContentController.removeAllUserScripts()
        if #available(iOS 14.0, *) {
            webView.configuration.userContentController.removeAllScriptMessageHandlers()
        } else {
            // Fallback on earlier versions
        }

        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.removeObserver(self, forKeyPath: "title")
        deallocPrint()
    }
}

private extension LRWebViewController {
    
    func addConfig() -> WKWebViewConfiguration {
        // 网页配置对象
        let config = WKWebViewConfiguration()
        
        // 配置对象的偏好设置
        let preference = WKPreferences()
        preference.minimumFontSize = 15 // 最小字体
        preference.javaScriptEnabled = true // 支持JavaScript
        preference.javaScriptCanOpenWindowsAutomatically = true // javaScript可以打开窗口
        
        config.preferences = preference
        config.allowsInlineMediaPlayback = true // 允许使用在线播放
        config.allowsPictureInPictureMediaPlayback = true // 画中画
        config.applicationNameForUserAgent = "ChinaDailyForiPad" // User-Agent
        
        config.userContentController = setWKUserContentController()
        
        return config
    }
    
    func setWKUserContentController() -> WKUserContentController {
        // WKUserContentController: 主要用来做native与js的交互管理
        
        let scriptMessageHandler = LRWeakScriptMessage(scriptDelegate: self)
        let userContent = WKUserContentController()
        
        // 监听JS方法 -- getJSFuncNoParams
        userContent.add(scriptMessageHandler, name: "jsToOcNoPrams")
        // 监听JS方法 -- getJSFuncWithParams
        userContent.add(scriptMessageHandler, name: "jsToOcWithPrams")
        
        userContent.addUserScript(setUserScript()) // 添加js注入
        
        return userContent
    }
    
    func setUserScript() -> WKUserScript {
        let jsString = """
        var meta = document.createElement('meta');
        meta.setAttribute('name', 'viewport');
        meta.setAttribute('content', 'width=device-width');
        document.getElementsByTagName('head')[0].appendChild(meta);
        """
        let wkUScript = WKUserScript(source: jsString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        return wkUScript
    }
}

private extension LRWebViewController {
    func getCookie() {
        let cookieStorage = HTTPCookieStorage.shared
        var JSFuncString = """
            function setCookie(name,value,expires)
            {
            var oDate=new Date();
            oDate.setDate(oDate.getDate()+expires);
            document.cookie=name+'='+value+';expires='+oDate+';path=/'
            }
            function getCookie(name)
            {
            var arr = document.cookie.match(new RegExp('(^| )'+name+'=([^;]*)(;|$)'));
            if(arr != null) return unescape(arr[2]); return null;
            }
            function delCookie(name)
            {
            var exp = new Date();
            exp.setTime(exp.getTime() - 1);
            var cval=getCookie(name);
            if(cval!=null) document.cookie= name + '='+cval+';expires='+exp.toGMTString();
            }
        """
        
        guard let cookieArr = cookieStorage.cookies else {
            return
        }
        for cookie in cookieArr {
            let tempStr = String(format: "setCookie('%@', '%@', 1)", arguments: [cookie.name, cookie.value])
            JSFuncString += tempStr
        }
        
        webView.evaluateJavaScript(JSFuncString) { _, _ in
            
        }
    }
}

extension LRWebViewController {
    
    private func settingProgress() {
        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        self.webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        Log.debug("网页加载进度---\(webView.estimatedProgress)")
        if keyPath == "estimatedProgress" {
            DispatchQueue.main.async {
                let viewProgress = Float(self.webView.estimatedProgress)
                self.progressView.setProgress(viewProgress, animated: true)
                if viewProgress >= 1.0 {
                    self.activityView.stopAnimating()
                    self.progressView.progress = 0
                }
            }
        } else if keyPath == "title" {
            if !self.showWebTitle {
                return
            }
            if self.navigationController?.navigationBar.isHidden ?? true {
                self.customNavView.title = webView.title
            } else {
                self.title = webView.title
            }
        }
    }
}

// MARK: UIScrollViewDelegate
extension LRWebViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !self.progressView.isHidden || webView.isLoading {
            return
        }
        var delta = scrollView.contentOffset.y / (self.navHeight() + self.statusBarHeight())
        delta = CGFloat.maximum(delta, 0)
        customNavView.alpha = CGFloat.minimum(delta, 1)
    }
}

// MARK: HSCustomWebNavigationProtocol
extension LRWebViewController: HSCustomWebNavigationProtocol {
    func hs_webGoBack() {
        if self.webView.canGoBack {
            self.webView.goBack()
        } else {
            if let _nav = self.navigationController {
                if (self.navigationController?.children.count ?? 1) > 1 {
                    _nav.popViewController(animated: true)
                } else {
                    if let _ = self.presentingViewController {
                        _nav.dismiss(animated: true)
                        return
                    }
                }
            } else {
                self.dismiss(animated: true)
            }
        }
    }
    
    func hs_webRefresh() {
        activityView.startAnimating()
        webView.reload()
    }
}

// MARK: WKUIDelegate 主要处理JS脚本，确认框，警告等
extension LRWebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        // HTML的弹框 弹窗。。。警告窗
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        // 弹窗。。。确认窗
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        // 弹框。。。输入框
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // 页面弹窗。。。是_blank处理
        if !(navigationAction.targetFrame?.isMainFrame ?? true) {
            webView.load(navigationAction.request)
        }
        return nil
    }
}

// MARK: WKNavigationDelegate 主要处理一些跳转，加载处理操作
extension LRWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.activityView.startAnimating()
        self.progressView.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.activityView.stopAnimating()
        self.progressView.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        // 当内容开始返回时。。。
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        self.getCookie()
        self.activityView.stopAnimating()
        self.progressView.isHidden = true
        customNavView.hideNav()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        // 提交发生错误。。。
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        // 接收到服务器跳转请求重定向。。。
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // 根据即将跳转的HTTP请求头信息和相关信息来决定是否跳转。。。
        decisionHandler(WKNavigationActionPolicy.allow)
        let headStr = "github://"
        if let urlStr = navigationAction.request.url?.absoluteString {
            if urlStr.hasPrefix(headStr) {
                let alertController = UIAlertController(title: "通过截取URL调用OC", message: "前往GitHub？", preferredStyle: .alert)
                let actionCancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                let actionOK = UIAlertAction(title: "打开", style: .default, handler: { action in
                    let url = "https://github.com/"
                    UIApplication.shared.open(URL(string: url)!)
                })
                
                alertController.addAction(actionCancel)
                alertController.addAction(actionOK)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
    }
    
    // 这个必须要实现响应方法，否则点击链接就会crash
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        // 根据客户端接收到的服务器响应头以及response相关信息来决定是否可以跳转。。。
        decisionHandler(WKNavigationResponsePolicy.allow)
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // 需要响应身份验证时调用，在闭包中传入用户身份凭证。。。
        // 当前身份信息
        let curCred = URLCredential(user: "姓名", password: "123", persistence: .none)
        // 给challenge的发送者提供身份信息
        challenge.sender?.use(curCred, for: challenge)
        // 回调信息
        completionHandler(URLSession.AuthChallengeDisposition.useCredential, curCred)
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        // 当进程被终止时调用。。。
    }
}

// MARK: WKScriptMessageHandler
extension LRWebViewController: WKScriptMessageHandler {
    
    // 处理js传递的消息
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        Log.debug("接受到JS传递的消息：\(message.name)")
    }
}

