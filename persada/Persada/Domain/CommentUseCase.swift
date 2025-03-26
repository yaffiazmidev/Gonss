//
//  CommentUseCase.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 24/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import RxSwift

protocol CommentUseCase {
	func getComments() -> Observable<Comment>
	func addComment() -> Observable<Void>
	func deleteComment() -> Observable<Void>
	func getSubComments() -> Observable<Subcomment>
	func deleteSubComment() -> Observable<Void>
	func addLikeSubComment(isLike: Bool) -> Observable<Void>
}
