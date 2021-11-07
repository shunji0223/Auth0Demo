//
//  ContentView.swift
//  Auth0Demo
//
//  Created by 朱駿璽 on 2021/11/02.
//

import SwiftUI
import Auth0
import SimpleKeychain

struct ContentView: View {
    
    var isAuthenticated = false
    let credentialsManager = CredentialsManager(authentication: Auth0.authentication())
    let keychain = A0SimpleKeychain(service: "Auth0")
    var credentials: Credentials?
    
    var body: some View {
        VStack{
            Text("Hello, world!")
                .padding()
        }
        VStack{
            Button(action: {
                SessionManager.shared.patchMode = false
                self.login()
            }){
                Text("Ω")
                    .font(.system(size: 80, weight: .bold))
                    .fontWeight(.heavy)
                    .foregroundColor(Color.red)
            }
        }
        VStack{
            Button(action: {
                self.logout()
            }){
                Text("ß")
                    .font(.system(size: 80, weight: .bold))
                    .fontWeight(.heavy)
                    .foregroundColor(Color.red)
            }
        }
    }
    
    func logout(){
        Auth0.webAuth().clearSession(federated: false){ result in
            if result {
                self.keychain.clearAll()
                self.credentialsManager.revoke{error in
                    guard error == nil else {
                        // Handle error
                        print("Error: \(String(describing: error))")
                        return}
                print("ログアウトOK")
                }
            }
        }
    }
    
    func login(){
        
        //guard let clientInfo = plistValues(bundle: Bundle.main) else { return }
        //var result = self.credentialsManager.hasValid()
        //var accesstoken = self.credentials?.accessToken
        
        if self.credentialsManager.hasValid(){
            /*
            let refreshToken = self.credentials?.refreshToken ?? nil
            Auth0
                .authentication()
                .renew(withRefreshToken: refreshToken!)
                .start{ result in
                    switch result {
                    case .success(let credentials):
                        guard let accessToken = credentials.accessToken,
                              let refreshToken = credentials.refreshToken else {return}
                        self.keychain.setString(accessToken, forKey: "access_token")
                        self.keychain.setString(refreshToken, forKey: "refresh_token")
                        print("accesstoken=\(String(describing: self.keychain.data(forKey: "access_token")))")
                        print("refreshtoken=\(refreshToken)")
                    case .failure(let error):
                        keychain.clearAll()
                        print(error)
                    }
                
                }
             */
        }
        else {
            Auth0
                .webAuth()
                .scope("openid profile")
                .audience("https://dev-63n9lm5u.jp.auth0.com/userinfo")
                .start { result in
                    switch result {
                    case .failure(let error):
                        print("Error:\(error)")
                        self.keychain.clearAll()
                    case .success(let credentials):
                        print("Credentials:\(credentials)")
                        //self.credentialsManager.store(credentials: credentials)
                        guard let accessToken = credentials.accessToken
                        else {return}
                        self.keychain.setString(accessToken, forKey: "access_token")
                        //self.keychain.setString(refreshToken, forKey: "refresh_token")
                        print("accesstoken=\(String(describing: self.keychain.data(forKey: "access_token")))")
                        //print("refreshtoken=\(refreshToken)")
                        
                    }
                }
            return
        }
            
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
