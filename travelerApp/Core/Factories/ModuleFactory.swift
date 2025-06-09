//
//  ModuleFactory.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 27.05.25.
//

class ModuleFactory {
    func makeLoginModule(coordinator: LoginViewModelDelegate) -> LoginViewController {
        let viewModel = LoginViewModel()
        viewModel.delegate = coordinator
        let viewController = LoginViewController(viewModel: viewModel)
        return viewController
    }
    
    func makeRegisterModule(coordinator: RegisterViewModelDelegate) -> RegisterViewController {
        let viewModel = RegisterViewModel()
        viewModel.delegate = coordinator
        let viewController = RegisterViewController(viewModel: viewModel)
        return viewController
    }
    
    func makeCreateTripModule(
        coordinator: CreateTripViewModelDelegate,
        title: String
    ) -> CreateTripViewController {
        let viewModel = CreateTripViewModel()
        viewModel.delegate = coordinator
        let viewController = CreateTripViewController(viewModel: viewModel)
        viewController.title = title
        return viewController
    }
    
    func makeProfileModule(
        coordinator: ProfileViewModelDelegate,
        authResponse: AuthResponse
    ) -> ProfileViewController {
        let viewModel = ProfileViewModel(authResponse: authResponse)
        viewModel.delegate = coordinator
        let viewController = ProfileViewController(viewModel: viewModel)
        return viewController
    }
    
    func makeTripListModule(
        coordinator: TripListViewModelDelegate,
        authResponse: AuthResponse
    ) -> TripListViewController {
        let viewModel = TripListViewModel(authResponse: authResponse)
        viewModel.delegate = coordinator
        let viewController = TripListViewController(viewModel: viewModel)
        return viewController
    }

    func makeParticipantsModule(
        coordinator: ParticipantsViewModelDelegate,
        tripData: CreateTripData,
        title: String
    ) -> ParticipantsViewController {
        let viewModel = ParticipantsViewModel(tripData: tripData)
        viewModel.delegate = coordinator
        let viewController = ParticipantsViewController(viewModel: viewModel)
        viewController.title = title
        return viewController
    }

    func makeBudgetDistributionModule(
        coordinator: BudgetDistributionViewModelDelegate,
        tripData: CreateTripData,
        trip: TripDto,
        participants: [String],
        title: String
    ) -> BudgetDistributionViewController {
        let viewModel = BudgetDistributionViewModel(
            tripData: tripData,
            trip: trip,
            participants: participants
        )
        viewModel.delegate = coordinator
        let viewController = BudgetDistributionViewController(viewModel: viewModel)
        viewController.title = title
        return viewController
    }

    func makeTripDetailsModule(
        coordinator: TripDetailsViewModelDelegate,
        trip: TripDto,
        title: String
    ) -> TripDetailsContainerViewController {
        let viewModel = TripDetailsViewModel(trip: trip)
        viewModel.delegate = coordinator
        let viewController = TripDetailsContainerViewController(viewModel: viewModel)
        viewController.title = title
        return viewController
    }
    
    func makeExpenseAddModule(
        coordinator: ExpenseAddViewModelDelegate,
        tripId: Int64,
        title: String
    ) -> ExpenseAddViewController {
        let viewModel = ExpenseAddViewModel(tripId: tripId)
        viewModel.delegate = coordinator
        let viewController = ExpenseAddViewController(viewModel: viewModel)
        viewController.title = title
        return viewController
    }
    
    func makeNotificationsModule(
        coordinator: NotificationsViewModelDelegate
    ) -> NotificationsViewController {
        let viewModel = NotificationsViewModel()
        viewModel.delegate = coordinator
        let viewController = NotificationsViewController(viewModel: viewModel)
        viewController.title = "Уведомления"
        return viewController
    }
}
