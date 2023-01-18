//
//  ContentView.swift
//  RSS
//
//  Created by Shyam Kumar on 1/11/23.
//

import SwiftUI

struct CategoriesView: View {
    @EnvironmentObject var session: SessionManager
    @StateObject var viewModel = ViewModel()
    @State var isSheetShowing = false
    @State var path: [Category] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(session.categories) { category in
                    NavigationLink(value: category) {
                        HStack(alignment: .center, spacing: 16) {
                            if let first = category.title.first {
                                Text(String(first).capitalized)
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(.white)
                                    .font(.headline)
                                    .background(colorFor(char: first))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            Text(category.title.capitalized)
                        }
                        .padding(8)
                    }
                }
            }
            .navigationDestination(for: Category.self) { category in
                if category.title.lowercased() != "all" {
                    CategoryFeedView(feedCategory: category)
                } else {
                    CategoryFeedView(feedCategory: nil)
                }
            }
            .navigationTitle("Categories")
            .task {
                await viewModel.loadCategories(from: session)
            }
            .toolbar {
                Button {
                    // toggle sheet
                    isSheetShowing = true
                } label: {
                    Image(systemName: "gear")
                }
            }
            .sheet(isPresented: $isSheetShowing) {
                SettingsView(shouldUseNativeViewer: session.dependencies.localStorage.readShouldUseNativeHTMLViewer())
                    .environmentObject(session)
            }
        }
    }
    
    func colorFor(char: Character) -> Color {
        switch char {
        case "A"..<"G":
            return .blue
        case "G"..<"M":
            return .mint
        case "M"..<"S":
            return .indigo
        default:
            return .pink
        }
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView()
            .environmentObject(SessionManager(dependencies: Dependencies()))
    }
}
