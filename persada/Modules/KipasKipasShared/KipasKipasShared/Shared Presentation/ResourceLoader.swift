import Combine

public typealias Closure<T> = ((T) -> Void)
public typealias EmptyClosure = (() -> Void)

public typealias API<Response, Failure: Error> = AnyPublisher<Response, Failure>

public protocol ResourceLoader {
    typealias LoadPublisher = (Parameter) -> API<Resource, AnyError>
    
    associatedtype Resource
    associatedtype Parameter
    
    var publisher: LoadPublisher { get }
}

public struct AnyResourceLoader<Param, Response>: ResourceLoader {
    public typealias LoadPublisher = (Param) -> API<Response, AnyError>
    
    public let publisher: LoadPublisher
    
    public init(publisher: @escaping LoadPublisher) {
        self.publisher = publisher
    }
}
