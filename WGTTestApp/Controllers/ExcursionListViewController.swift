import UIKit

class ExcursionListViewController: UIViewController {

    @IBOutlet weak var listTableView: UITableView!
    let listTableViewCellID = "excursionCellID"
    
    var excursionList: [ExcursionModel] = []
    let api = APIUnsplash()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listTableView.delegate = self
        listTableView.dataSource = self

        setUpExcursions()
        
    }
    
    fileprivate func setUpExcursions() {
        api.fetchPhotos(for: "Krasnodar") { urlStringArray in
            let newOne = ExcursionModel(name: "Краснодар, прогулка",
                                        steps: [ExcursionStepModel(name: "Улица Красная", text: "Улица Красная в Краснодаре является центральной улицей и главной артерией города. Именно на этой улице сосредоточены основные достопримечательности города, а также скверы, площади, фонтаны, зеленая прогулочная аллея, памятники, административные здания, театры, музеи и кинотеатры. К тому же на улице множество кафе и ресторанов, магазинов и большой торгово-развлекательный центр «Галерея Краснодар», любимое место местной молодежи. Если вы хотите поближе познакомиться с Краснодаром, то ваш путь, несомненно, должен проходить через улицу Красную. В различных частях улицы проводят праздничные мероприятия, концерты, а по улице проходят парады. В выходные и праздничные дни, часть улицы Красной, от улицы Советской до улицы Пашковской, перекрывают от движения транспорта, и эта часть улицы становится полностью пешеходной. В это время на улице выступают уличные артисты, выходят торговцы сувенирами и всякой всячиной, а местные жители и гости города гуляют, катаются на роликах и велосипедах и просто отдыхают",
                                                                   imagesURLs: urlStringArray, audioURL: Bundle.main.url(forResource: "audio", withExtension: ".mp3")!)])
            
            self.excursionList.append(newOne)
            DispatchQueue.main.async {
                self.listTableView.reloadData()
            }
        }
    }
}


extension ExcursionListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return excursionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = listTableView.dequeueReusableCell(withIdentifier: listTableViewCellID)!
        
        cell.textLabel?.text = excursionList[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        listTableView.deselectRow(at: indexPath, animated: true)
        
        let vc = storyboard?.instantiateViewController(identifier: "mainVC") as! MainViewController
        vc.currentExcursion = excursionList[indexPath.row]
        
        present(vc, animated: true, completion: nil)
        
    }
    
}

