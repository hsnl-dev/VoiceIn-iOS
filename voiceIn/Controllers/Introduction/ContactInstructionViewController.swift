import UIKit
import Instructions

internal class ContactInstructionViewController: ContactTableViewController, CoachMarksControllerDataSource {
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coachMarksController?.dataSource = self
    }
    
    //MARK: - Protocol Conformance | CoachMarksControllerDataSource
    func numberOfCoachMarksForCoachMarksController(coachMarksController: CoachMarksController) -> Int {
        return 3
    }
    
    func coachMarksController(coachMarksController: CoachMarksController, coachMarksForIndex index: Int) -> CoachMark {
        switch(index) {
        case 0:
            return coachMarksController.coachMarkForView(self.navigationController?.navigationBar) { (frame: CGRect) -> UIBezierPath in
                return UIBezierPath(rect: frame)
            }
        case 1:
            return coachMarksController.coachMarkForView(self.navigationItem.rightBarButtonItems?[0].valueForKey("view") as? UIView) { (frame: CGRect) -> UIBezierPath in
                return UIBezierPath(rect: frame)
            }
        case 2:
            return coachMarksController.coachMarkForView(self.navigationItem.rightBarButtonItems?[1].valueForKey("view") as? UIView) { (frame: CGRect) -> UIBezierPath in
                return UIBezierPath(rect: frame)
            }
        default:
            return coachMarksController.coachMarkForView()
        }
    }
    
    func coachMarksController(coachMarksController: CoachMarksController, coachMarkViewsForIndex index: Int, coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        
        let coachViews = coachMarksController.defaultCoachViewsWithArrow(true, arrowOrientation: coachMark.arrowOrientation)
        
        switch(index) {
        case 0:
            coachViews.bodyView.hintLabel.text = self.startText
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        case 1:
            coachViews.bodyView.hintLabel.text = self.addFriendText
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        case 2:
            coachViews.bodyView.hintLabel.text = self.cardText
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        default: break
        }
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
}
