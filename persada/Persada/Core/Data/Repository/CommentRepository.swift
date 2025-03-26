//
//  CommentRepository.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 24/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import RxSwift

protocol CommentRepository {
	func queryComments() -> Observable<[Comment]>
	func querySubComments() -> Observable<[Subcomment]>
	func addLike(isLike: Bool) -> Observable<Void>
	func addComment(value: Comment) -> Observable<Void>
	func deleteComment() -> Observable<Void>
	func addLikeSubComment() -> Observable<Void>
}

class CommentRepositoryImpl {

}
