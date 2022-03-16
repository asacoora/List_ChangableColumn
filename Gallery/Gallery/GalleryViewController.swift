//
//  GalleryViewController.swift
//  Gallery
//

import UIKit

class GalleryViewController: UIViewController {
                                                        
    @IBOutlet weak var collectionView: UICollectionView!
    var images : [GalleryImage]?
    var isMulticolums = false
    var currentImgCount = 0 {
        didSet{
            DispatchQueue.main.async {
                self.title = "\(self.currentImgCount)"
            }
        }
    }
    @IBOutlet weak var errorView: UIView!
    
    // ----- 코드 수정 제한 영역 시작 -----
    /// 다운로드한 이미지의 총 개수
    private var imageCount: Int = .zero {
        didSet {
            DispatchQueue.main.async {
                self.title = "\(self.imageCount)"
            }
        }
    }
    // ----- 코드 수정 제한 영역 끝 -----

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        // ----- 코드 수정 제한 영역 시작 -----
        assert(self.navigationController != nil, "self.navigationController must not be nil")
        self.title = "Gallery"
        setNavigationBarButtons()
        setNotificationObserver()
        
        // ----- 코드 수정 제한 영역 끝 -----

        // GalleryRequest 사용 예시 (확인 후 제거 가능)
        
        GalleryRequest(display: 10, start: currentImgCount + 1).send() { result in
            switch result {
            case .success(let data):
                self.images = data.images
                self.currentImgCount += self.currentImgCount + 10
                
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
            case .failure(let error):
                print("error: \(error)")
                DispatchQueue.main.async {
                    self.errorView.isHidden = false
                }
            }
        }
        
        
    }

    // ----- 코드 수정 제한 영역 시작 -----
    private func setNavigationBarButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshButtonDidTap))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Change", style: .plain, target: self, action: #selector(changeButtonDidTap))
    }

    private func setNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(countDownloadedImages), name: .init("DownloadImageDidFinish"), object: nil)
    }
    // ----- 코드 수정 제한 영역 끝 -----

    /// 새로고침 버튼을 누르면 실행되는 함수
    ///
    /// 데이터를 처음부터 다시 불러 오고 컬렉션뷰의 스크롤을 최상단으로 위치시킨다.
    @objc func refreshButtonDidTap() {
        self.images = nil
        self.errorView.isHidden = true
        currentImgCount = 0
        self.collectionView.reloadData()
        GalleryRequest(display: 10, start: currentImgCount + 1).send() { result in
            switch result {
            case .success(let data):
                self.images = data.images
                self.currentImgCount += self.currentImgCount + 10
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
            case .failure(let error):
                print("error: \(error)")
                DispatchQueue.main.async {
                    self.errorView.isHidden = false
                }
            }
        }
    }

    /// Change 버튼을 누르면 실행되는 함수
    ///
    /// 컬렉션뷰의 레이아웃을 단일 컬럼과 3중 컬럼으로 번갈아가며 보여준다.
    @objc func changeButtonDidTap() {
        //print("change")
        self.isMulticolums = !self.isMulticolums
        self.collectionView.reloadData()
    }

    /// Image 다운로드를 완료할 때마다 불리는 함수
    @objc func countDownloadedImages() {

        // ----- 코드 수정 제한 영역 시작 -----
        self.imageCount += 1
        // ----- 코드 수정 제한 영역 끝 -----
        

    }
}
extension GalleryViewController : UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if (self.currentImgCount >= 1000) {
            return
        }
        
        if (indexPath.row == self.images!.count - 1){
                
            GalleryRequest(display: 10, start: self.currentImgCount + 1).send() { result in
                switch result {
                case .success(let data):
                    
                    for d in data.images!{
                        self.images?.append(d)
                    }
                    self.currentImgCount += self.currentImgCount + 10
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                    
                case .failure(let error):
                    print("error: \(error)")
                    DispatchQueue.main.async {
                        self.errorView.isHidden = false
                    }
                }
            }
        }
        
        
    }
}
extension GalleryViewController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (self.isMulticolums ){
            let colCnt = 3;
            
            let width = (self.collectionView.frame.width / CGFloat(colCnt) ) - 10.0
            let height = width
            
            return CGSize(width: width, height: height)
        }
        
        
        print(self.collectionView.frame.width)
        return CGSize(width: self.collectionView.frame.width, height: 50.0)
    }
}
extension GalleryViewController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (self.images == nil){
            return 0
        }
        print (self.images!.count)
        self.imageCount = self.images!.count
        return self.images!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (isMulticolums){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "catcell2", for: indexPath) as! CatCell2
            let url = URL(string: (self.images?[indexPath.row].link)!)
            let data = try! Data(contentsOf: url!)
            cell.link.image = UIImage(data: data)
            
            return cell
            
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "catcell", for: indexPath) as! CatCell
        cell.title.text = self.images?[indexPath.row].title
        
        let url = URL(string: (self.images?[indexPath.row].link)!)
        let data = try! Data(contentsOf: url!)
        cell.link.image = UIImage(data: data)
        
        return cell
    }
    
    
}
class CatCell : UICollectionViewCell{
    
    @IBOutlet weak var link: UIImageView!
    @IBOutlet weak var title: UILabel!
    
}
class CatCell2 : UICollectionViewCell{
    @IBOutlet weak var link: UIImageView!
}
