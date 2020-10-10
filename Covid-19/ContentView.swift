//
//  ContentView.swift
//  Covid-19
//
//  Created by 이주한(UI) and 이연호(API)
//

import SwiftUI

struct Header: Codable {
    var resultCode: String
    var resultMsg: String
}

struct Item: Codable {
    // var accDefRate: Float
    var accExamCnt: Int
    var accExamCompCnt: Int
    var careCnt: Int
    var clearCnt: Int
    var createDt: String
    var deathCnt: Int
    var decideCnt: Int
    var examCnt: Int
    var resutlNegCnt: Int
    var seq: Int
    var stateDt: Int
    var stateTime: String
    var updateDt: String
}

struct Items: Codable {
    var item: [Item]
}

struct Body: Codable {
    var items: Items
    var numOfRows: Int
    var pageNo: Int
    var totalCount: Int
}

struct Response: Codable {
    var header: Header
    var body: Body
}

struct CovidResponse: Codable {
    var response: Response
}

public struct Covid { // 코로나 확진자, 완치자, 사망자 구조체
    public var confirmed: Int // 확진자
    public var clear: Int // 완치자
    public var died: Int // 사망자
}

func makeCovidStruct(item: Item) -> Covid {
    return Covid(
        confirmed: item.decideCnt,
        clear: item.clearCnt,
        died: item.deathCnt
    )
}

func subtractCovid(a: Covid, b: Covid) -> Covid {
    return Covid(
        confirmed: a.confirmed - b.confirmed,
        clear: a.clear - b.clear,
        died: a.died - b.died
    )
}

var key: String = "yt2%2B9e%2F%2FbAdG8XgY0%2BF4I0lpWjdyRAWrtCG%2B%2FsCMJyqHSNR67r5pa26oRvHh9pZx4mEs83QjbquODCUYXir70w%3D%3D"

public var uri: String = "http://openapi.data.go.kr/openapi/service/rest/Covid19/getCovid19InfStateJson"
public var args = "?serviceKey=\(key)&numOfRows=10&pageNo=1&startCreateDt=20201001&_type=json"
public var apiURL: String = uri + args

var data: Data? = nil
var isFinished = false
var showingAlert = true
var allFinished = false

let decoder = JSONDecoder()

func getDateString(date: Int) -> String {
    return String(date/10000) + "/" + String(date/100-date/10000*100) + "/" + String(date-date/100*100)
}

struct ContentView: View {
    @State var today: Covid = Covid(confirmed: 69, clear: 72, died: 1)

    @State var all: Covid = Covid(confirmed: 22052, clear: 20538, died: 295)
    
    @State var updateTime: String = "2020/10/09 11:00:00"
    
    func reloadInfo() {
        while(!allFinished) {
            do {
                let task = URLSession.shared.dataTask(with: URL(string: apiURL)!) { d, response, error in
                    data = d
                    isFinished = true
                }
                task.resume()
                while(!isFinished) {}
                isFinished = false
                let cr = try decoder.decode(CovidResponse.self, from: data!)
                all = makeCovidStruct(item: cr.response.body.items.item[0])
                let ydSum = makeCovidStruct(
                    item: cr.response.body.items.item[1]
                )
                today = subtractCovid(a: all, b: ydSum)
                updateTime = getDateString(date: cr.response.body.items.item[0].stateDt) + " " + cr.response.body.items.item[0].stateTime
                allFinished = true
            } catch {
                print("Error occured. Retrying..")
                print(error)
            }
        }
        allFinished = false
    }
    
    var body: some View {
        NavigationView{
            Form{
                Section(header: Text("Today")) {
                    Text("확진자: \(today.confirmed)")
                    Text("완치자: \(today.clear)")
                    Text("사망자: \(today.died)")
                }
                Section(header: Text("all")) {
                    Text("확진자: \(all.confirmed)")
                    Text("완치자: \(all.clear)")
                    Text("사망자: \(all.died)")
                }
                Text("UPDATED ON \(updateTime)") // 기준 시간
                Button("새로고침"){
                    reloadInfo()
                }
            }.navigationBarTitle("COVID-19")
        }.onAppear(perform: reloadInfo)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


// other
