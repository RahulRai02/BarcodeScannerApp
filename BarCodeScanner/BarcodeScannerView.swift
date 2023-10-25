//
//  ContentView.swift
//  BarCodeScanner
//
//  Created by Rahul Rai on 13/10/23.
//

import SwiftUI

struct BarcodeScannerView: View {
    @State private var scannedCode = ""
    var body: some View {
        NavigationView{
            VStack{
                ScannerView(scannedCode: $scannedCode)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: 300)
                
                Spacer()
                    .frame(height: 60)
                
                Label("Scanned Barcode:",
                      systemImage: "barcode.viewfinder")
                .font(.title)
                Text(scannedCode.isEmpty ? "Not yet scanned" : scannedCode)
                    .bold()
                    .font(.largeTitle)
                    .foregroundColor(scannedCode.isEmpty ? .red : .green)
                    .padding()
            }
            .navigationTitle("Barcode Scanner")
        }
        
    }
}

struct ContentView_Preview: PreviewProvider{
    static var previews: some View{
        BarcodeScannerView()
    }
}


