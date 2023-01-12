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
        func loadCategories(from session: SessionManager) async {
            _ = await session.loadCategories()
        }
    }
}
