//
//  ContentView.swift
//  BelieveAndRiseSwiftUI
//
//  Created by MasterBel2 on 21/9/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import SwiftUI
import UberserverClientCore

final class ViewModel: ObservableObject {
    weak var client: Client!

    @Published var username: String?
}

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        ZStack {
            if viewModel.username != nil {
                BattleList(list: UberserverClientCore.List<Battle>(title: "", sorter: UberserverClientCore.PropertySorter<Battle, String>(property: { $0.founder })))
            } else {
                LoginView(userAuthenticationController: viewModel.client.userAuthenticationController)
            }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

struct BattleList: View {
    let list: UberserverClientCore.List<Battle>

    var body: some View {
        ForEach(0..<list.sortedItemsByID.count) { index in
            if let battle = list.item(at: index) {
                BattleListItem(battle: battle)
            }
        }
    }
}

struct BattleListItem: View {
    let battle: Battle

    var body: some View {
        return Text(battle.founder)
    }
}

struct LoginView: View {
    @State var username: String = ""
    @State var password: String = ""
    @State var currentError: String = ""
    @State var isWaitingForResponse: Bool = false

    let userAuthenticationController: UserAuthenticationController

    var body: some View {
            VStack {
                TextField("Username", text: $username)
                SecureField("Password", text: $password)
                Button("Login", action: submitLogin)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .disabled(isWaitingForResponse)
        }
    }

    private func submitLogin() {
        isWaitingForResponse = true
        userAuthenticationController.submitLogin(username: username, password: password, completionHandler: { result in
            isWaitingForResponse = false
            switch result {
            case .failure(let error):
                currentError = error.description
            case .success(_):
                break
            }
            print(result)
        })
    }
}

final class LoginViewModel {
    let userAuthenticationController: UserAuthenticationController
    init(userAuthenticationController: UserAuthenticationController) {
        self.userAuthenticationController = userAuthenticationController
    }


}

extension LocalizedStringKey {
    static var usernameEntryTitle: LocalizedStringKey { "usernameentrytitle" }
}
