//
//  ViewController.swift
//  TrueFalseStarter
//
//  Created by Pasan Premaratne on 3/9/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import UIKit
import GameKit
import AudioToolbox

class ViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var questionField: UILabel!
    @IBOutlet weak var resultsLabel: UILabel!
    @IBOutlet weak var option1Button: UIButton!
    @IBOutlet weak var option2Button: UIButton!
    @IBOutlet weak var option3Button: UIButton!
    @IBOutlet weak var option4Button: UIButton!
    @IBOutlet weak var nextQuestionButton: UIButton!
    
    let questionsPerRound = 10
    var questionsAsked = 0
    var correctQuestions = 0
    var indexOfSelectedQuestion: Int = 0
    var indexOfQuestionsAsked = [Int]()
    
    var gameSound: SystemSoundID = 0
    
    let quizQuestions = QuizQuestions()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        loadGameStartSound()
        // Start game
        playGameStartSound()
        displayQuestion()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK: Functions
    func displayQuestion() {
        getQuestion()
//        indexOfSelectedQuestion = GKRandomSource.sharedRandom().nextInt(upperBound: quizQuestions.trivia.count)
//        let questionDictionary = quizQuestions.trivia[indexOfSelectedQuestion]
//        questionField.text = questionDictionary["Question"]
//        option1Button.setTitle(questionDictionary["Option1"], for: .normal)
//        option2Button.setTitle(questionDictionary["Option2"], for: .normal)
//        option3Button.setTitle(questionDictionary["Option3"], for: .normal)
//        option4Button.setTitle(questionDictionary["Option4"], for: .normal)
//        nextQuestionButton.isHidden = true
    }
    
    func getQuestion() {
        indexOfSelectedQuestion = GKRandomSource.sharedRandom().nextInt(upperBound: quizQuestions.trivia.count)
        if [indexOfSelectedQuestion] == indexOfQuestionsAsked {
            while [indexOfSelectedQuestion] == indexOfQuestionsAsked {
                indexOfSelectedQuestion = GKRandomSource.sharedRandom().nextInt(upperBound: quizQuestions.trivia.count)
            }
        }
        let questionDictionary = quizQuestions.trivia[indexOfSelectedQuestion]
        indexOfQuestionsAsked += [indexOfSelectedQuestion]
        questionField.text = questionDictionary["Question"]
        option1Button.setTitle(questionDictionary["Option1"], for: .normal)
        option2Button.setTitle(questionDictionary["Option2"], for: .normal)
        option3Button.setTitle(questionDictionary["Option3"], for: .normal)
        option4Button.setTitle(questionDictionary["Option4"], for: .normal)
        nextQuestionButton.isHidden = true
        
    }
    
    func displayScore() {
        // Hide the answer buttons
        option1Button.isHidden = true
        option2Button.isHidden = true
        option3Button.isHidden = true
        option4Button.isHidden = true
        questionField.isHidden = true
        
        // Display play again button
        nextQuestionButton.isHidden = false
        
        resultsLabel.text = "You got \(correctQuestions) out of \(questionsPerRound) correct!"
        
    }
    
    @IBAction func checkAnswer(_ sender: UIButton) {
        // Increment the questions asked counter
        questionsAsked += 1
        
        let selectedQuestionDict = quizQuestions.trivia[indexOfSelectedQuestion]
        let correctAnswer = selectedQuestionDict["Answer"]
        
        if (sender === option1Button &&  correctAnswer == option1Button.currentTitle) || (sender === option2Button && correctAnswer == option2Button.currentTitle) {
            correctQuestions += 1
            questionField.text = "Correct!"
        } else {
            questionField.text = "Sorry, wrong answer!"
        }
        
        loadNextRoundWithDelay(seconds: 2)
    }
    
    func nextRound() {
        if questionsAsked == questionsPerRound {
            // Game is over
            displayScore()
        } else {
            // Continue game
            displayQuestion()
        }
    }
    
    @IBAction func playAgain() {
        // Show the answer buttons
        option1Button.isHidden = false
        option2Button.isHidden = false
        option3Button.isHidden = false
        option4Button.isHidden = false
        
        questionsAsked = 0
        correctQuestions = 0
        nextRound()
    }
    

    
    // MARK: Helper Methods
    func loadNextRoundWithDelay(seconds: Int) {
        // Converts a delay in seconds to nanoseconds as signed 64 bit integer
        let delay = Int64(NSEC_PER_SEC * UInt64(seconds))
        // Calculates a time value to execute the method given current time and delay
        let dispatchTime = DispatchTime.now() + Double(delay) / Double(NSEC_PER_SEC)
        
        // Executes the nextRound method at the dispatch time on the main queue
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            self.nextRound()
        }
    }
    
    func loadGameStartSound() {
        let pathToSoundFile = Bundle.main.path(forResource: "GameSound", ofType: "wav")
        let soundURL = URL(fileURLWithPath: pathToSoundFile!)
        AudioServicesCreateSystemSoundID(soundURL as CFURL, &gameSound)
    }
    
    func playGameStartSound() {
        AudioServicesPlaySystemSound(gameSound)
    }
}

