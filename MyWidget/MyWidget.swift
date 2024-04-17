//
//  MyWidget.swift
//  MyWidget
//
//  Created by Reales Rectoro Myles Clarence on 15/04/24.
//

import WidgetKit
import SwiftUI

// MODELO VAR
struct Modelo : TimelineEntry {
    var date: Date
    var widgetData : [JsonData]
}

struct JsonData: Decodable {
    var id : Int
    var name : String
    var email: String
}

// PROVIDER
struct Provider : TimelineProvider {
    func placeholder(in context: Context) -> Modelo {
        return Modelo(date: Date(), widgetData: Array(repeating: JsonData(id: 0, name: "", email: ""), count: 2))
    }
    
    func getSnapshot(in context: Context, completion: @escaping (Modelo) -> Void) {
        completion(Modelo(date: Date(), widgetData: Array(repeating: JsonData(id: 0, name: "", email: ""), count: 2)))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Modelo>) -> Void) {
        getJson{(modelData) in
            let data = Modelo(date: Date(), widgetData: modelData)
            guard let update = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) else {return}
                    let timeline = Timeline(entries: [data], policy: .after(update))
            completion(timeline)
        }
    }
    
    typealias Entry = Modelo
    
}

func getJson(completation: @escaping ([JsonData]) -> ()){
    guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1/comments") else { return }
    
    URLSession.shared.dataTask(with: url){data,_,_ in
        guard let data = data else { return }
        
        do{
            let json = try JSONDecoder().decode([JsonData].self, from: data)
            DispatchQueue.main.async {
                completation(json)
            }
        }catch let error as NSError {
            print("fallo", error.localizedDescription)
        }
    }.resume()
}

//DISEÑO - VISTA
struct vista: View {
    let entry : Provider.Entry
    var body: some View{
        VStack(alignment: .leading){
            Text("Mi lista").font(.title).bold()
            ForEach(entry.widgetData, id: \.id){ item in
                Text(item.name).bold()
                    Text(item.email)
            }
        }
    }
}

// CONFIGURACIÓN
@main
struct HelloWidget: Widget {
    var body: some WidgetConfiguration{
        StaticConfiguration(kind: "Widget", provider: Provider()){ entry in
            vista(entry: entry)
        }.description("Descripción del widget")
            .configurationDisplayName("Nombre widget")
            .supportedFamilies([.systemLarge])
    }
}
