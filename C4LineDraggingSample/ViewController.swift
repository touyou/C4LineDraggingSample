//
//  ViewController.swift
//  C4LineDraggingSample
//
//  Created by 藤井陽介 on 2016/07/30.
//  Copyright © 2016年 touyou. All rights reserved.
//

import UIKit
import C4

class ViewController: CanvasController {
    // Outlet Collectionという機能
    @IBOutlet var pointButton: [UIButton]!
    // 指についてくる線の配列（配列じゃなくてもいいかも...?）
    var line = [Line]()
    // 繋がった線の配列
    var answerLine = [Line]()
    // ボタンのフレームの配列
    var buttonFrame = [CGRect]()
    // ボタンの中心座標の配列
    var buttonCenter = [Point]()
    // 訪れたボタンのリスト
    var setList = [Int]()
    // 始点の座標を入れておく
    var beforeCenter: Point!
    // タッチし始めから何個ボタンを通過したか
    var index: Int = 0
    
    override func setup() {
    }
    
    // Storyboardでの座標が定まってから開始
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // ボタンの座標を取得する
        for button in pointButton {
            buttonFrame.append(button.frame)
            buttonCenter.append(Point(Double(button.frame.midX), Double(button.frame.midY)))
        }
        
        index = 0
        canvas.addPanGestureRecognizer { location, center, translation, velocity, state in
            ShapeLayer.disableActions = true
            
            // 下でエラーを出さないように
            if self.index >= self.line.count {
                return
            }
            if state == .Ended {
                if self.line.count > self.index {
                    self.line[self.index].removeFromSuperview()
                }
            }
            // beforeCenterには始点の情報がcenterには指の位置が入っていてそこまでの直線を書く
            self.line[self.index].endPoints = (self.beforeCenter, center)
            for i in 0 ..< self.buttonFrame.count {
                // setListにはすでに訪れた点が入っている
                if self.setList.contains(i) {
                    continue
                }
                let tFrame = self.buttonFrame[i]
                // ボタンのフレームに手が入っていったか
                if Double(tFrame.origin.x) <= center.x && Double(tFrame.origin.x+tFrame.width) >= center.x &&
                    Double(tFrame.origin.y) <= center.y && Double(tFrame.origin.y+tFrame.height) >= center.y {
                    // 伸ばしている線は消す
                    self.line[self.index].removeFromSuperview()
                    // answerLineがつなぐ線
                    self.answerLine.append(Line(begin: self.beforeCenter, end: self.buttonCenter[i]))
                    self.answerLine[self.index].lineWidth = 10          // 線幅
                    self.answerLine[self.index].strokeColor = C4Pink    // 線の色
                    self.canvas.add(self.answerLine[self.index])
                    // たどりついた点を次の始点に
                    self.beforeCenter = self.buttonCenter[i]
                    self.index += 1
                    self.setList.append(i)
                    if self.index != 8 {
                        // 訪れたボタンのところから新しい線を出し始める
                        self.line.append(Line(begin: self.beforeCenter, end: self.beforeCenter))
                        self.line[self.index].anchorPoint = self.beforeCenter
                        self.line[self.index].lineWidth = 10
                        self.line[self.index].strokeColor = C4Blue
                        self.canvas.add(self.line[self.index])
                    }
                    break
                }
            }
            if self.index == 8 {
                NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(ViewController.initProperty), userInfo: nil, repeats: false)
            }
        }
    }
    
    // 最初に線を伸ばし始めるときはタッチと同時に描画し始めたいのでtouchesBeganで
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("began")
        for touch in touches {
            let location = touch.locationInView(self.view)
            let center = Point(Double(location.x), Double(location.y))
            if self.line.isEmpty {
                for i in 0 ..< self.buttonFrame.count {
                    let bFrame = buttonFrame[i]
                    if Double(bFrame.origin.x) <= center.x && Double(bFrame.origin.x+bFrame.width) >= center.x &&
                        Double(bFrame.origin.y) <= center.y && Double(bFrame.origin.y+bFrame.height) >= center.y {
                        line.append(Line(begin: buttonCenter[i], end: buttonCenter[i]))
                        line[0].anchorPoint = buttonCenter[i]
                        line[0].lineWidth = 10
                        line[0].strokeColor = C4Blue
                        canvas.add(line[0])
                        beforeCenter = buttonCenter[i]
                        setList.append(i)
                        return
                    }
                }
            } else if line.count > index {
                canvas.add(line[index])
            }
        }
    }
    
    func initProperty() {
        line.removeAll()
        for al in answerLine {
            al.removeFromSuperview()
        }
        answerLine.removeAll()
        setList.removeAll()
        index = 0
    }
}
