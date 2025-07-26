//
//  MovieDetailViewController.swift
//  Networking 2
//
//  Created by lilit on 26.07.25.
//
import UIKit
class MovieDetailViewController: UIViewController {
    var movie: Movie!

    let posterImageView = UIImageView()
    let titleLabel = UILabel()
    let metadataLabel = UILabel()
    let descriptionLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
        configure()
    }

    private func setupViews() {
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true

        titleLabel.font = .boldSystemFont(ofSize: 24)

        metadataLabel.font = .systemFont(ofSize: 16)
        metadataLabel.textColor = .darkGray
        metadataLabel.numberOfLines = 0

        descriptionLabel.font = .systemFont(ofSize: 18)
        descriptionLabel.numberOfLines = 0
        
        [posterImageView, titleLabel, metadataLabel, descriptionLabel].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(posterImageView)
        view.addSubview(titleLabel)
        view.addSubview(metadataLabel)
        view.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            posterImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            posterImageView.widthAnchor.constraint(equalToConstant: 180),
            posterImageView.heightAnchor.constraint(equalToConstant: 240),

            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            metadataLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            metadataLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            metadataLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: metadataLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }

    private func configure() {
        titleLabel.text = movie.name
        metadataLabel.text = """
        First Air Date: \(movie.firstAirDate)
        Rating: \(movie.voteAverage)
        Countries: \(movie.originCountry.joined(separator: ", "))
        Popularity: \(Int(movie.popularity))
        """
        descriptionLabel.text = movie.overview

        if let url = URL(string: MovieURL.imageURL(for: .posterPath, path: movie.posterPath)) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.posterImageView.image = image
                    }
                }
            }.resume()
        }
    }
}
