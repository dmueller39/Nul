//
//  ContentView.swift
//  Unbrowsable
//
//  Created by Daniel Mueller on 3/17/25.
//

import SwiftUI
import WebKit


struct WebView: UIViewRepresentable {
    @ObservedObject var viewModel: WebViewModel
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        viewModel.webView = webView
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.viewModel.currentURL = webView.url?.absoluteString ?? ""
        }
    }
}

class WebViewModel: ObservableObject {
    @Published var webView: WKWebView?
    @Published var currentURL: String = ""
    
    func goBack() {
        webView?.goBack()
    }
    
    func goForward() {
        webView?.goForward()
    }
    
    func shareURL() {
        guard let url = URL(string: currentURL) else { return }
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true, completion: nil)
        }
    }
    
    func load(url: URL) {
        webView?.load(URLRequest(url: url))
    }
}

struct ContentView: View {
    @StateObject var viewModel: WebViewModel
    
    init(viewModel: WebViewModel = WebViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            WebView(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
            HStack {
                Button(action: viewModel.goBack) {
                    Image(systemName: "chevron.backward")
                }
                .disabled(viewModel.webView?.canGoBack == false)
                
                Spacer()
                
                Button(action: viewModel.shareURL) {
                    Image(systemName: "square.and.arrow.up")
                }

                Spacer()
                
                Button(action: viewModel.goForward) {
                    Image(systemName: "chevron.forward")
                }
                .disabled(viewModel.webView?.canGoForward == false)
            }
            .padding()
        }
        .onOpenURL { url in
            viewModel.load(url: url)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = WebViewModel()
        let testURL = URL(string: "https://www.google.com")!
        
        return ContentView(viewModel: viewModel)
            .onAppear {
                viewModel.load(url: testURL) // Simulate incoming URL
            }
    }
}

