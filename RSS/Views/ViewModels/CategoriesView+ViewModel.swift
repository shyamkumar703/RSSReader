//
//  CategoriesView+ViewModel.swift
//  RSS
//
//  Created by Shyam Kumar on 1/11/23.
//

import Foundation

extension CategoriesView {
    @MainActor class ViewModel: ObservableObject {
        @Published var categories = [Category]()
        
        func loadCategories(from dependencies: HasAPI) async {
            let result = await dependencies.api.call(with: GetCategoriesRequest())
            switch result {
            case .success(let categories):
                self.categories = categories.sorted()
            case .failure(let error):
                print(error)
            }
        }
    }
}
