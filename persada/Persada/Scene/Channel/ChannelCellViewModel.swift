//
//  ChannelCellViewModel.swift
//  Persada
//
//  Created by Muhammad Noor on 08/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

struct ChannelCellViewModel {
    
    let name: String?
    let description: String?
    let id: String?
    let imageUrl: String?
    let code: String?

    init?(value: Channel?) {

        guard let name: String = value?.name,
            let description: String = value?.descriptionField,
            let id: String = value?.id,
            let imageUrl: String = value?.photo,
              let code: String = value?.code
                else {
                return nil
        }

        self.id = id
        self.name = name
        self.description = description
        self.imageUrl = imageUrl
        self.code = code
    }
}
