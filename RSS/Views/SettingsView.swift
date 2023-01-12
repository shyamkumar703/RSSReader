//
//  SettingsView.swift
//  RSS
//
//  Created by Shyam Kumar on 1/12/23.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var session: SessionManager
    @State var shouldUseNativeViewer: Bool
    var body: some View {
        ZStack {
            Color(uiColor: UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Text("K")
                    .frame(width: 100, height: 100)
                    .background(.pink)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .foregroundColor(.white)
                    .font(.largeTitle)
                
                List {
                    Section("Settings") {
                        HStack {
                            Text("Use native HTML viewer")
                            Spacer()
                            Toggle("Use native HTML viewer", isOn: $shouldUseNativeViewer)
                                .labelsHidden()
                                .onChange(of: shouldUseNativeViewer) { newValue in
                                    session.dependencies.localStorage.save(shouldUseNativeHTMLViewer: newValue)
                                }
                        }
                    }
                }
            }
            .padding(.vertical, 24)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(shouldUseNativeViewer: true)
            .environmentObject(SessionManager(dependencies: Dependencies()))
    }
}
