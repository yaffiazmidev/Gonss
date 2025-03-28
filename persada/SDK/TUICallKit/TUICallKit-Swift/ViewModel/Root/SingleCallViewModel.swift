//
//  SingleCallViewModel.swift
//
//
//  Created by vincepzhang on 2022/12/30.
//

import TUICallEngine

class SingleCallViewModel {
 
    let callStatusObserver = Observer()
    let mediaTypeObserver = Observer()
    let selfCallRoleObserver = Observer()
    let remoteUserListObserver = Observer()

    let selfCallStatus: Observable<TUICallStatus> = Observable(.none)
    let selfCallRole: Observable<TUICallRole> = Observable(.none)
    let mediaType: Observable<TUICallMediaType> = Observable(.unknown)
    let remoteUserList: Observable<[User]> = Observable(Array())
    
    let enableFloatWindow = TUICallState.instance.enableFloatWindow
    
    init() {
        selfCallStatus.value = TUICallState.instance.selfUser.value.callStatus.value
        selfCallRole.value = TUICallState.instance.selfUser.value.callRole.value
        mediaType.value = TUICallState.instance.mediaType.value
        remoteUserList.value = TUICallState.instance.remoteUserList.value

        registerObserve()
    }
    
    deinit {
        TUICallState.instance.selfUser.value.callRole.removeObserver(selfCallRoleObserver)
        TUICallState.instance.selfUser.value.callStatus.removeObserver(callStatusObserver)
        TUICallState.instance.mediaType.removeObserver(mediaTypeObserver)
        TUICallState.instance.remoteUserList.removeObserver(remoteUserListObserver)
    }
    
    func registerObserve() {
        
        TUICallState.instance.selfUser.value.callRole.addObserver(selfCallRoleObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.selfCallRole.value = newValue
            
            print("SingleCallViewModel-callRole")
        })
        
        TUICallState.instance.selfUser.value.callStatus.addObserver(callStatusObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.selfCallStatus.value = newValue
            print("SingleCallViewModel-callStatus")

        })
        
        TUICallState.instance.mediaType.addObserver(mediaTypeObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.mediaType.value = newValue
            print("SingleCallViewModel-mediaType")

        })
        
        TUICallState.instance.remoteUserList.addObserver(remoteUserListObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.remoteUserList.value = newValue
            print("SingleCallViewModel-remoteUserList")
        })
    }
}
