//
//  MovieView.swift
//  Networking 2
//
//  Created by lilit on 26.07.25.
//
import UIKit

class MovieView: UIView {
    let posterImageView = UIImageView()
    let titleLabel = UILabel()
    let metadataLabel = UILabel()
    let descriptionLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.backgroundColor = .lightGray

        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.numberOfLines = 1

        metadataLabel.font = .systemFont(ofSize: 13)
        metadataLabel.textColor = .darkGray
        metadataLabel.numberOfLines = 4

        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 5

        [posterImageView, titleLabel, metadataLabel, descriptionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            posterImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            posterImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            posterImageView.widthAnchor.constraint(equalToConstant: 90),
            posterImageView.heightAnchor.constraint(equalToConstant: 120),
            posterImageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -12),

            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: posterImageView.topAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            metadataLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            metadataLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            metadataLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: metadataLabel.bottomAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -12)
        ])
    }

    func configure(with movie: Movie) {
        titleLabel.text = movie.name
        metadataLabel.text = """
        First Air Date - \(movie.firstAirDate)
        Rating - \(movie.voteAverage)
        Countries - \(movie.originCountry.joined(separator: ", "))
        Popularity - \(Int(movie.popularity))
        """
        descriptionLabel.text = movie.overview

        if let url = URL(string: MovieURL.imageURL(for: .posterPath, path: movie.posterPath)) {
            loadImage(from: url)
        } else {
            posterImageView.image = nil
        }
    }

    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.posterImageView.image = image
                }
            }
        }.resume()
    }
}
