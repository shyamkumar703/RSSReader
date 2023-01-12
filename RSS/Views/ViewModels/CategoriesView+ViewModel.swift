//
//  CategoriesView+ViewModel.swift
//  RSS
//
//  Created by Shyam Kumar on 1/11/23.
//

import Foundation
import SwiftUI

extension CategoriesView {
    @MainActor class ViewModel: ObservableObject {
        @Published var categories = [Category]()
        
        func loadCategories(from session: SessionManager) async {
            let result = await session.loadCategories()
            switch result {
            case .success(let categories):
                withAnimation {
                    self.categories = categories.sorted()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
