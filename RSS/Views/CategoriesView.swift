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
    
    var body: some View {
        NavigationView {
            List {
                ForEach(session.categories) { category in
                    NavigationLink {
                        if category.title.lowercased() != "all" {
                            CategoryFeedView(feedCategory: category)
                        } else {
                            CategoryFeedView(feedCategory: nil)
                        }
                    } label: {
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
            .navigationTitle("Categories")
            .task {
                await viewModel.loadCategories(from: session)
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
