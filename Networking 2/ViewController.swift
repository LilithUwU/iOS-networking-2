//
//  ViewController.swift
//  Networking 1
//
//  Created by lilit on 26.07.25.
//


import UIKit
import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingFailed(Error)
    case requestFailed(Error)
}

struct Movie: Decodable {
    let name: String
    let firstAirDate: String
    let voteAverage: Double
    let originCountry: [String]
    let popularity: Double
    let posterPath: String
    let backdropPath: String
    let overview: String

    enum CodingKeys: String, CodingKey {
        case name
        case firstAirDate = "first_air_date"
        case voteAverage = "vote_average"
        case originCountry = "origin_country"
        case popularity
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case overview
    }
}

struct MovieURL {
    static let baseURL = "https://api.themoviedb.org/3/tv"
    static let imageBaseURL = "https://image.tmdb.org/t/p/w500"
    static let endpoint = "top_rated"

    enum ImageEndpoint: String {
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
    }

    struct Parameters {
        static let apiKey = "7481bbcf1fcb56bd957cfe9af78205f3"
        static let language = "en-US"
        static let page = "1"
    }

    static func imageURL(for imageType: ImageEndpoint, path: String) -> String {
        let formattedPath = path.hasPrefix("/") ? path : "/" + path
        return "\(imageBaseURL)\(formattedPath)"
    }
}





import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var movies = [Movie]()
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Home"
        view.backgroundColor = .systemBackground
        
        setupTableView()
        fetchMovieList()
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: MovieTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 160
        tableView.rowHeight = UITableView.automaticDimension
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func fetchMovieList() {
        let urlString = "\(MovieURL.baseURL)/\(MovieURL.endpoint)?api_key=\(MovieURL.Parameters.apiKey)&language=\(MovieURL.Parameters.language)&page=\(MovieURL.Parameters.page)"
        
        guard let url = URL(string: urlString) else {
            handleError(.invalidURL)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                self?.handleError(.requestFailed(error))
                return
            }
            
            guard let data = data else {
                self?.handleError(.noData)
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(TMDBResponse.self, from: data)
                self?.movies = decodedResponse.results
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            } catch {
                self?.handleError(.decodingFailed(error))
            }
        }.resume()
    }
    
    func handleError(_ error: NetworkError) {
        DispatchQueue.main.async {
            switch error {
            case .invalidURL:
                print("Error: Invalid URL")
            case .noData:
                print("Error: No data received")
            case .decodingFailed(let decodingError):
                print("Error decoding JSON: \(decodingError.localizedDescription)")
            case .requestFailed(let requestError):
                print("Network request failed: \(requestError.localizedDescription)")
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMovie = movies[indexPath.row]
        let detailVC = MovieDetailViewController()
        detailVC.movie = selectedMovie
        navigationController?.pushViewController(detailVC, animated: true)
        tableView.allowsSelection = true
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier, for: indexPath) as? MovieTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: movies[indexPath.row])
        return cell
    }
}



struct TMDBResponse: Decodable {
    let results: [Movie]
}
