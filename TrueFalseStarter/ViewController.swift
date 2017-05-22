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
    @IBOutlet weak var selectModePopupConstraint: NSLayoutConstraint!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var popupBlurEffect: UIVisualEffectView!
    
    // Game mode booleans
    var gameModeSelected = false
    var lightningModeSelected = false
    
    // Lightning Mode
    var seconds = 15
    var isTimerRunning = false
    var timer = Timer()
    
    
    // Quiz properties
    let questionsPerRound = 10
    var questionsAsked = 0
    var correctQuestions = 0
    var indexOfSelectedQuestion: Int = 0
    var indexOfQuestionsAsked = [Int]()
    
    // Button colors
    let buttonBlue = UIColor(red: 12/255, green: 121/255, blue: 150/255, alpha: 1)
    let buttonGreen = UIColor(red: 0/255, green: 147/255, blue: 135/255, alpha: 1)
    let buttonRed = UIColor(red: 153/255, green: 29/255, blue: 50/255, alpha: 1)
    
    var gameSound: SystemSoundID = 0
    
    let quizQuestions = QuizQuestions()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
//        loadGameStartSound()
//        // Start game
//        playGameStartSound()
        hideAll()
        displayModeSelector()
        popupView.layer.cornerRadius = 10
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK: Functions
    func displayQuestion() {
        getQuestion()

    }
    
    // Function to display the question
    func getQuestion() {
        // Reset button function
        buttonFunctionState(sender1: option1Button, sender2: option2Button, sender3: option3Button, sender4: option4Button, function: true)
        
        // Making sure button backgrounds are normal
        resetButtonBackground(sender1: option1Button, sender2: option2Button, sender3: option3Button, sender4: option4Button)
        
        // Reset the Next Question Button
        nextQuestionButton.setTitle("Next Question", for: .normal)
        
        // show the question and results label
        questionField.text = ""
        resultsLabel.text = ""
        questionField.isHidden = false
        resultsLabel.isHidden = false
        // Make sure options are visible
        showState(sender1: option1Button, sender2: option2Button, sender3: option3Button, sender4: option4Button, state: false)
        // Check to see if need to run timer
        if lightningModeSelected == true {
            runTimer()
        }
        // Get the initial random number
        indexOfSelectedQuestion = GKRandomSource.sharedRandom().nextInt(upperBound: quizQuestions.trivia.count)
        // Loop to make sure we don't use this same number
        while indexOfQuestionsAsked.contains(indexOfSelectedQuestion) {
            indexOfSelectedQuestion = GKRandomSource.sharedRandom().nextInt(upperBound: quizQuestions.trivia.count)
        }
        // After passing the loop, assigning to a temp constant
        let questionDictionary = quizQuestions.trivia[indexOfSelectedQuestion]
        // Appending to array to make sure we don't use this number again
        indexOfQuestionsAsked.append(indexOfSelectedQuestion)
        // Putting text in the boxes
        questionField.text = questionDictionary["Question"]
        option1Button.setTitle(questionDictionary["Option1"], for: .normal)
        option2Button.setTitle(questionDictionary["Option2"], for: .normal)
        option3Button.setTitle(questionDictionary["Option3"], for: .normal)
        option4Button.setTitle(questionDictionary["Option4"], for: .normal)
        nextQuestionButton.isHidden = true
        
        // Increment the questions asked counter
        questionsAsked += 1
    }
    
    
    // End of game function to display score
    func displayScore() {
        // Hide the answer buttons
        showState(sender1: option1Button, sender2: option2Button, sender3: option3Button, sender4: option4Button, state: true)
        
        // Show the result
        resultsLabel.text = "You got \(correctQuestions) out of \(questionsPerRound) correct!"
        
        // Reset
        indexOfQuestionsAsked.removeAll()
        questionsAsked = 0
        correctQuestions = 0
        gameModeSelected = false
        lightningModeSelected = false
        
        nextQuestionButton.setTitle("Play Again", for: .normal)
    }
    
    
    // Func to change the button appearance when it's not selected
    func changeBackgroundFor(notSender: UIButton) {
        notSender.alpha = 0.3
        notSender.tintColor = UIColor.lightText
    }
    
    
    // Show or hide the buttons
    func showState(sender1: UIButton, sender2: UIButton, sender3: UIButton, sender4: UIButton, state: Bool) {
        sender1.isHidden = state
        sender2.isHidden = state
        sender3.isHidden = state
        sender4.isHidden = state
    }
    
    // Function to make buttons normal again
    func resetButtonBackground(sender1: UIButton, sender2: UIButton, sender3: UIButton, sender4: UIButton) {
        sender1.backgroundColor = buttonBlue
        sender1.tintColor = UIColor.white
        sender1.alpha = 1
        sender2.backgroundColor = buttonBlue
        sender2.tintColor = UIColor.white
        sender2.alpha = 1
        sender3.backgroundColor = buttonBlue
        sender3.tintColor = UIColor.white
        sender3.alpha = 1
        sender4.backgroundColor = buttonBlue
        sender4.tintColor = UIColor.white
        sender4.alpha = 1
    }
    
    
    // Function to control the timer
    func updateTimer() {
        resultsLabel.text = "\(seconds)" // Displaying the seconds
        seconds -= 1  // To count down the seconds
        if seconds == -1 {
            timer.invalidate()
            buttonFunctionState(sender1: option1Button, sender2: option2Button, sender3: option3Button, sender4: option4Button, function: false)
            resultsLabel.text = "Out of time"
            nextQuestionButton.isHidden = false
        }
    }
    
    
    // Function to format the timer
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
        seconds = 15
    }
    
    
    // Function to present the mode selector
    func displayModeSelector() {
        if gameModeSelected == false {
            selectModePopupConstraint.constant = 0
        }
        popupBlurEffect.alpha = 0.55
        UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded()})
    }
    
    
    
    //MARK: The main func
    func nextRound() {
        if questionsAsked == questionsPerRound {
            // Game is over
            displayScore()
        } else if gameModeSelected == false {
            displayModeSelector()
        } else {
            // Continue game
            displayQuestion()
        }
    }
    
    
    func hideAll() {
        questionField.isHidden = true
        resultsLabel.isHidden = true
        resultsLabel.text = ""
        option1Button.isHidden = true
        option2Button.isHidden = true
        option3Button.isHidden = true
        option4Button.isHidden = true
        nextQuestionButton.isHidden = true
    }
    
    
    func buttonFunctionState(sender1: UIButton, sender2: UIButton, sender3: UIButton, sender4: UIButton, function: Bool) {
        sender1.isEnabled = function
        sender2.isEnabled = function
        sender3.isEnabled = function
        sender4.isEnabled = function
    }
    
    
    
    //MARK: Actions
    @IBAction func nextQuestion(_ sender: Any) {
        nextRound()
    }
    
    // Func to check the answer 
    @IBAction func checkAnswer(_ sender: UIButton) {
        
        let selectedQuestionDict = quizQuestions.trivia[indexOfSelectedQuestion]
        let correctAnswer = selectedQuestionDict["Answer"]
        
        if sender.currentTitle == correctAnswer {
            correctQuestions += 1
            resultsLabel.text = "Correct!"
            resultsLabel.isHidden = false
            sender.backgroundColor = buttonGreen
        } else {
            resultsLabel.text = "Sorry, wrong answer!"
            resultsLabel.isHidden = false
            sender.backgroundColor = buttonRed
        }
        if option1Button != sender {
            changeBackgroundFor(notSender: option1Button)
        }
        if option2Button != sender {
            changeBackgroundFor(notSender: option2Button)
        }
        if option3Button != sender {
            changeBackgroundFor(notSender: option3Button)
        }
        if option4Button != sender {
            changeBackgroundFor(notSender: option4Button)
        }
        nextQuestionButton.isHidden = false
        timer.invalidate()
    }
    
    // Action for Lightning mode
    @IBAction func lightningModeButtonPressed(_ sender: Any) {
        selectModePopupConstraint.constant = -300
        gameModeSelected = true
        
        UIView.animate(withDuration: 0.1, animations: {self.view.layoutIfNeeded()})
        lightningModeSelected = true
        getQuestion()
        
        popupBlurEffect.alpha = 0
    }
    
    // Action for Normal mode
    @IBAction func normalModeButtonPressed(_ sender: Any) {
        selectModePopupConstraint.constant = -300
        popupBlurEffect.alpha = 0
        gameModeSelected = true
        UIView.animate(withDuration: 0.1, animations: {self.view.layoutIfNeeded()})
        getQuestion()
        
        popupBlurEffect.alpha = 0
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

