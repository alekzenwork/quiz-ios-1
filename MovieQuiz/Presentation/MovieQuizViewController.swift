import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    
    
    // MARK: - IB Outlets
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var questionTitleLabel: UILabel!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    
    // MARK: - Private Properties    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactory?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    // MARK: - View Life Cycles
    override func viewDidLoad() {

        var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "inception.json"
        documentsURL.appendPathComponent(fileName)
        let jsonString = try? String(contentsOf: documentsURL)
        
        do {
            if let data = jsonString?.data(using: .utf8) {
                _ = try JSONDecoder().decode(Movie.self, from: data)
                // Теперь у вас есть декодированный объект `movie`
            } else {
                print("Failed to convert JSON string to data")
            }
        } catch {
            print("Failed to parse: \(error.localizedDescription)")
        }

        
        
        
        
        
                 /*
        var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        enum FileManagerError: Error {
            case fileDoesntExist
        }
        
        func string(from documentsURL: URL) throws -> String {
            // проверяем существует ли файл
            if !FileManager.default.fileExists(atPath: documentsURL.path) {
                // прокидываем ошибку
                throw FileManagerError.fileDoesntExist
            }
            // файл существует, а значит возвращаем значение
            return try String(contentsOf: documentsURL)
        }
        var str = ""
        
        do {
            str = try string(from: documentsURL)
        } catch FileManagerError.fileDoesntExist {
            print("Файл по адресу \(documentsURL.path) не существует")
        } catch {
            print("Неизвестная ошибка чтения из файла \(error)")
            print(str)
        }
        */
        
        /*
        //получаем адрес папки Documents
        var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        //создаем основу для будущего файла
        var fileName = "text.swift"
        //добавили в конец адреса имя файла для его создания
        documentsURL.appendPathComponent(fileName)
        //проверям существует ли имя файла по указанному адресу
        
        if !FileManager.default.fileExists(atPath: documentsURL.path) {
            let hello = "Hello world!"
            let data = hello.data(using: .utf8)
            FileManager.default.createFile(atPath: documentsURL.path, contents: data)
        }
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
        */
        
        /*
        do {
            str = try string(from: documentsURL)
        } catch FileManagerError.fileDoesntExist {
            print("Файл по адресу \(documentsURL.path) не существует")
        } catch {
            print("Неизвестная ошибка чтения из файла \(error)")
        }
        */
        
        
        questionFactory = QuestionFactory(delegate: self)
        alertPresenter = AlertPresenter(viewController: self)
        super.viewDidLoad()

        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23.0)
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        
        questionFactory?.requestNextQuestion()
    }
    
    //MARK: - QuesstionFactoryDelegate
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
    
    // MARK: - IB Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        }
    
    // MARK: - Private Methods
    // приватный метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber:
                "\(currentQuestionIndex + 1) / \(questionsAmount)")
        return questionStep
    }
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(title: "Этот раунд окончен" ,
                                    message: "Ваш результат: \(correctAnswers)/10",
                                    buttonText: "Сыграть ещё раз",
                                    buttonAction: { [weak self] in
            self?.currentQuestionIndex = 0
            self?.correctAnswers = 0
            self?.questionFactory?.requestNextQuestion()
        }
    )
        alertPresenter?.show(alertModel: alertModel)
    }
    
    // приватный метод, который меняет цвет рамки
    // принимает на вход булевое значение и ничего не возвращает
    private func showAnswerResult(isCorrect: Bool) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in //слабая сслыка на self
            guard let self = self else { return } // разворачиваем слабую ссылку
            self.showNextQuestionOrResults()
        }
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            // идём в состояние "Результат квиза"
            let text = correctAnswers == questionsAmount ?
                        "Поздравляем, вы ответили на 10 из 10!" :
                        "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            let viewModel = QuizResultsViewModel( // 2
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            
            show(quiz: viewModel)
            
            imageView.layer.borderWidth = 0
            imageView.layer.borderColor = UIColor.clear.cgColor
        } else { // 2
            currentQuestionIndex += 1
            // идём в состояние "Вопрос показан"
            questionFactory?.requestNextQuestion()
            imageView.layer.borderWidth = 0
            imageView.layer.borderColor = UIColor.clear.cgColor
        }
    }
    

}
/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
