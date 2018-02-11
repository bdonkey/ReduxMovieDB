//
//  MoviesViewController.swift
//  ReduxMovieDB
//
//  Created by Matheus Cardoso on 2/11/18.
//  Copyright © 2018 Matheus Cardoso. All rights reserved.
//

import ReSwift
import RxCocoa
import RxSwift

class MoviesViewController: UIViewController {
    let disposeBag = DisposeBag()

    @IBOutlet weak var moviesTableView: UITableView! {
        willSet {
            newValue?.rx.itemSelected
                .map { $0.row }
                .filter { $0 < store.state.movies.count }
                .map(AppStateAction.selectMovieIndex)
                .bind(onNext: store.dispatch)
                .disposed(by: disposeBag)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        store.subscribe(self, transform: {
            $0.select(MoviesViewState.init)
        })
    }
}

// MARK: StoreSubscriber

extension MoviesViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = MoviesViewState

    func newState(state: MoviesViewState) {
        moviesTableView.reloadData()

        if let row = state.selectedMovieIndex {
            let indexPath = IndexPath(row: row, section: 0)
            self.moviesTableView.selectRow(at: indexPath, animated: true, scrollPosition: .none )
        } else if let selectedRows = moviesTableView.indexPathsForSelectedRows {
            selectedRows.forEach {
                self.moviesTableView.deselectRow(at: $0, animated: true)
            }
        }
    }
}

// MARK: UITableViewDataSource

extension MoviesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.state.movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)

        cell.textLabel?.text = store.state.movies[indexPath.row].name

        return cell
    }
}
