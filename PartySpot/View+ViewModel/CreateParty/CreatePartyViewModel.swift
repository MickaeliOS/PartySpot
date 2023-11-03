//
//  CreatePartyViewModel.swift
//  PartySpot
//
//  Created by Mickaël Horn on 19/10/2023.
//

import Combine
import UIKit

final class CreatePartyViewModel: ObservableObject {
    
    // MARK: - INPUT & OUTPUT
    enum Input {
        case fetchUser(userID: String)
    }
    
    enum Output {
        case fetchUserDidSucceed(user: User)
        case fetchUserDidFailed(error: Error)
    }
    
    // MARK: - PROPERTIES
    private let firestoreService: FirestoreServiceProtocol
    private let output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - INIT
    init(firestoreService: FirestoreServiceProtocol = FirestoreService()) {
        self.firestoreService = firestoreService
    }
    
    // MARK: - FUNCTIONS
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .fetchUser(let userID):
                self?.handleFetchUser(userID: userID)
            }
        }
        .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    private func handleFetchUser(userID: String) {
        firestoreService.fetchUser(userID: userID)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.output.send(.fetchUserDidFailed(error: error))
                }
            } receiveValue: { [weak self] user in
                self?.output.send(.fetchUserDidSucceed(user: user))
            }
            .store(in: &cancellables)
    }
}
