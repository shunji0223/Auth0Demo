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
    
    /*
    func plistValues(bundle: Bundle) -> (clientId: String, domain: String)? {
        guard
            let path = bundle.path(forResource: "Auth0", ofType: "plist"),
            let values = NSDictionary(contentsOfFile: path) as? [String: Any]
            else {
                print("Missing Auth0.plist file with 'ClientId' and 'Domain' entries in main bundle!")
                return nil
            }
        guard
            let clientId = values["ClientId"] as? String,
            let domain = values["Domain"] as? String
            else {
                print("Auth0.plist file at \(path) is missing 'ClientId' and/or 'Domain' entries!")
                print("File currently has the following entries: \(values)")
                return nil
            }
        return (clientId: clientId, domain: domain)
    }
     */
    func logout(){
        Auth0.webAuth().clearSession(federated: false){ result in
            if result {
                self.keychain.clearAll()
                self.credentialsManager.revoke{error in
                    guard error == nil else {
                        // Handle error
                        print("Error: \(error)")
                        return}
                print("ログアウトOK")
                }
            }
        }
    }
    
    func login(){
        
        //guard let clientInfo = plistValues(bundle: Bundle.main) else { return }
        var result = self.credentialsManager.hasValid()
        var acc = self.credentials?.accessToken
        
        if self.credentialsManager.hasValid(){
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
                        else {
                                  return
                              }
                        self.keychain.setString(accessToken, forKey: "access_token")
                        //self.keychain.setString(refreshToken, forKey: "refresh_token")
                        print("accesstoken=\(String(describing: self.keychain.data(forKey: "access_token")))")
                        //print("refreshtoken=\(refreshToken)")
                        
                    }
                }
            return
        }
            
        
    }
    
    /*
    func logout(){
        self.credentialsManager.revoke { error in
            guard error == nil else {
                // Handle error
                print("Error: \(error)")
                return
            }

            // The user is now logged out
        }
    }
     */
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
