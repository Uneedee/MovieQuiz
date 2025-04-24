import UIKit
final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - Константы, переменные (включая @IBOutlet, @published и др).
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenterDelegate: AlertPresenter?
    private var statisticService: StatisticServiceProtocol?
    private var currentDate = Date()
    
    // MARK: - Жизненный цикл
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService()
        showLoadingIndicator()
        questionFactory?.loadData()
        let presenter = AlertPresenter()
        presenter.viewController = self
        alertPresenterDelegate = presenter
        statisticService = StatisticService()
    }
    
    // MARK: - Обработчики действий
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return }
        let givenAnswer = false
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer )
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return }
        let givenAnswer = true
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer )
    }
    
    // MARK: - Приватные вспомогательные методы
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
            guard let question = question else {
                return
            }
            
            currentQuestion = question
            let viewModel = convert(model: question)
            
            DispatchQueue.main.async { [weak self] in
                self?.show(quiz: viewModel)
            }
        }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor(named: "Green")?.cgColor : UIColor(named: "Red")?.cgColor
        
        if isCorrect == true {
            correctAnswers += 1
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden =  true
        activityIndicator.stopAnimating()
    }
    
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(
            title: "Ошибка",
            message:  message,
            buttonText: "Попробовать ещё раз",
            completion: { [weak self] in
                guard let self = self else { return }
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            } )
        
        alertPresenterDelegate?.show(model: model)
        
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    
    private func showNextQuestionOrResults() {
        
        
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            let text = correctAnswers == questionsAmount ? "Поздравляем, вы ответили на 10 из 10!" :
            
            "Ваш результат \(correctAnswers)/\(questionsAmount)\n Количество сыгранных квизов: \(statisticService?.gamesCount ?? 0) \n Рекорд: \(statisticService?.bestGame.correct ?? 0)/\(statisticService?.bestGame.total ?? 0) (\(statisticService?.bestGame.date.dateTimeString ?? Date().dateTimeString)) \n Средняя точность: \(String(format: "%.2f", statisticService?.totalAccuracy ?? 0))"
            
            let viewModel = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть ещё раз",
                completion: { [weak self] in
                    guard let self = self else { return }
                    self.currentQuestionIndex = 0
                    self.correctAnswers = 0
                    self.questionFactory?.requestNextQuestion()
                } )
            
            alertPresenterDelegate?.show(model: viewModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
        
    }
    
    // MARK: - Вложенные структуры

    

    
    
}



