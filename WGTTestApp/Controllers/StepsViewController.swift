import UIKit

class StepsViewController: UIViewController {
    
    var currentExcursion: ExcursionModel? = nil
    var currentStepIndex: Int? = nil

    @IBOutlet weak var excursionNameLabel: UILabel!
    
    @IBOutlet weak var stepsTableView: UITableView!
    let stepCellID = "stepCellID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        excursionNameLabel.text = currentExcursion?.name
        
        stepsTableView.delegate = self
        stepsTableView.dataSource = self
        stepsTableView.allowsSelection = false
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func turnOffButtonPressed(_ sender: Any) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
}


extension StepsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentExcursion?.steps.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = stepsTableView.dequeueReusableCell(withIdentifier: stepCellID)!
        let currentStepNumber = String(indexPath.row + 1)
        let allSteps = String(currentExcursion?.steps.count ?? 0)
        let counter = currentStepNumber + "/" + allSteps + " "
        let currentStepName = String(describing: currentExcursion?.steps[indexPath.row].name ?? "")
        cell.textLabel?.text =  counter + currentStepName
        return cell
    }

    
}
