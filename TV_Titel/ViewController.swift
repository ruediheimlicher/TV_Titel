//
//  ViewController.swift
//  TV_Titel
//
//  Created by Ruedi Heimlicher on 15.08.2019.
//  Copyright © 2019 Ruedi Heimlicher. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, FileManagerDelegate
{
   var pfad = ""
   @IBOutlet weak var lblFileName: NSTextField!
   @IBOutlet weak var spinner: NSProgressIndicator!

   override func viewDidLoad() 
   {
      super.viewDidLoad()
      var a = 0x3fc00
      for i in (0...18)
      {
        // print("i: \(i)")
         var st = String(format:"%02X", a)
 //        print("a: \(st)")
         var b = String(Int(a), radix: 2)
 //        print("b: \(b)") // "1111101011001110"
         a = (a>>1)
      }
      // Do any additional setup after loading the view.
      var counter:UInt8 = 0
      for i in (0...18)
      {
         let k = counter & 0x03
 //        print("i: \(i) counter: \(counter)  k: \(k)")
         counter += 1
      }
   }

   @IBAction  func report_Open(_ sender: NSButton) // 
   {
      print("Pfad: *\(pfad)*")
      let openPanel = NSOpenPanel()
      openPanel.canChooseFiles = false
      openPanel.allowsMultipleSelection = false
      openPanel.canChooseDirectories = true
      openPanel.canCreateDirectories = false
      openPanel.title = "Select a folder"
      
      openPanel.beginSheetModal(for:self.view.window!) { (response) in
         if response.rawValue == NSApplication.ModalResponse.OK.rawValue 
         {
            let selectedPath = openPanel.url!.path
            // do whatever you what with the file path
            Swift.print("path: \(selectedPath)")
            self.pfad = selectedPath
         }
         openPanel.close()
      }
      
   }
   
   @IBAction  func report_Convert(_ sender: NSButton) // 
   {
      print("Pfad: *\(pfad)*")
      spinner.startAnimation(nil)  
      
      let fileManager = FileManager.default
      
        
     // let documentsDirectory = paths[0]

      
      // https://www.hackingwithswift.com/example-code/system/how-to-read-the-contents-of-a-directory-using-filemanager
      do {
         let items = try fileManager.contentsOfDirectory(atPath: pfad)
         
         for item in items 
         {
            print("\t \(item)")
         }

         
         for item in items 
         {
            // 2020-05-30_13_45_ZDF_Inga-Lindstroem-Sommer-der-Erinnerung-00.03.11.879-01.30.41.619.mp4
            //print("Found \(item)")
            var namenarray =  item.components(separatedBy: "_")
            //print("namenarray.count \(namenarray.count)")
            
            if item.contains(".csv")
            {
               let pfadURL = URL(fileURLWithPath: pfad,isDirectory: false)
               let originURL = pfadURL.appendingPathComponent(item)
               var exURL:URL = pfadURL.deletingLastPathComponent()
               print("exURL: \(exURL)")
               exURL = exURL.appendingPathComponent("ex")
               exURL = exURL.appendingPathComponent(item)
               print("exURL end: \(exURL)")
               do 
               {
                  try FileManager.default.moveItem(at: originURL, to: exURL)
                  
               } catch let error as NSError 
               {
                  print(error)
               }

            }
            
            else if (namenarray.count > 3)
            {
               
               // separated mit _
               
               print("\n***  namenarray:")
               for z in 3..<namenarray.count
               {
                  print("\(z) zeile: \(namenarray[z])")
               }
               
               //print("namenarray datum \(namenarray[0]) ")
               let datumarray =  namenarray[0].components(separatedBy: "-")
   //            for z in 0..<datumarray.count
   //            {
   //               print("\(z) zeile: \(datumarray[z])")
   //            }

               
               let jahrteil = datumarray[0].suffix(2) // Jahr 4-stellig
               let monatteil = datumarray[1]    // monat mm
               let tagteil = datumarray[2]      // tag dd
               let datumteil = "\(jahrteil)\(monatteil)\(tagteil)"
               //print("datumzahl: \(datumteil)") // datum als zahl
               
               let tvsender = namenarray[3]
               //print("sender: \(tvsender)")
               
               
               // suffix weg: letztes Element
               let teile = namenarray.count
               // https://stackoverflow.com/questions/24034398/new-array-from-index-range-swift
               let titelslice = namenarray[4...(teile-1)]
               let titelarray = Array(titelslice)
               //let titelarray = namenarray[namenarray.count - 1].components(separatedBy: ".")
              /*
               print("titelarray:")
               for z in 0..<titelarray.count
               {
                  print("\t\(z) zeile: \(titelarray[z])")
               }
               */
              // print("titelarray: \(titelarray[0])")
               var titelzeile = tvsender + " "
               var tvsuffix = ""
               for z in 0..<titelarray.count
               {
                  var tempzeile = titelarray[z]
                 
                  let elementarray = tempzeile.components(separatedBy:".")
                  tempzeile = elementarray[0]
                  if elementarray.count > 1 // suffix suchen
                  {
                     tvsuffix = elementarray.last ?? ".mp4"
                     print("z: /(z) suffix: \(tvsuffix)")
                  }
                  tempzeile = tempzeile.components(separatedBy:"-cut-")[0]
                  //print("lastzeile B: \(lastzeile)")
                  tempzeile = tempzeile.components(separatedBy:"-00")[0]
                  //print("lastzeile C: \(lastzeile)")
                  tempzeile = tempzeile.replacingOccurrences(of:"-",with:" ")
                  //print("z: \(z) tempzeile: \(tempzeile)")
                  if !titelzeile.contains(tempzeile)
                  {
                     if z == titelarray.count - 1
                     {
                        titelzeile = titelzeile + tempzeile
                     }
                     else
                     {
                        titelzeile = titelzeile + tempzeile + " "
                     }
                  }
               }
               titelzeile = titelzeile + "." + tvsuffix
               print("titelzeile: \(titelzeile)")
               var a = 0
               /*
               var firstzeile = titelarray.first
               firstzeile = firstzeile?.replacingOccurrences(of:"-",with:" ")
               print("firstzeile A: \(firstzeile)")
               
               var lastzeile = titelarray.last
               lastzeile = lastzeile?.components(separatedBy:".")[0]
               //print("lastzeile A: \(lastzeile)")
               lastzeile = lastzeile?.components(separatedBy:"-cut-")[0]
               //print("lastzeile B: \(lastzeile)")
               lastzeile = lastzeile?.components(separatedBy:"-00")[0]
               //print("lastzeile C: \(lastzeile)")
               lastzeile = lastzeile?.replacingOccurrences(of:"-",with:" ")
               print("lastzeile D: \(lastzeile)")
               */
               
               var titelteil = "\(titelarray[0]).\(titelarray[titelarray.count - 1])" 
               // erster und letzter teil
               
               
               titelteil = titelteil.replacingOccurrences(of:"-00",with:"")
               titelteil = titelteil.replacingOccurrences(of:"-",with:" ")
 //              var titelteilarray = titelteil.components(separatedBy: "-")
 //              var suffixteil = titelteilarray.last
 //              suffixteil = suffixteil?.replacingOccurrences(of:"00",with:" ")
               
               
               
               //print("titelteil: \(titelteil)")
               let neuername = "\(datumteil) \(titelzeile)"
               print("neuername: \(neuername) pfad: \(pfad)")
               

             
               var newpfad = "\(pfad)/\(item)"
               //https://stackoverflow.com/questions/35158215/rename-file-in-documentdirectory
               let pfadURL = URL(fileURLWithPath: pfad,isDirectory: false)
               let originURL = pfadURL.appendingPathComponent(item)
               let perm = [FileAttributeKey : Any]()
               
               
               //print("perm: \(perm)")
               //print("originURL: \(String(describing: originURL))")
               
               let destinationURL = pfadURL.appendingPathComponent(neuername)
               //print("destinationURL: \(String(describing: destinationURL))")
               
               
               do 
               {
                  try FileManager.default.moveItem(at: originURL, to: destinationURL)
                  
               } catch let error as NSError 
               {
                  print(error)
               }
                
            }
         } // for item
      } catch {
        print("failed to read directory – bad permissions, perhaps?")
         spinner.stopAnimation(nil) 
      }
      
      let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
      do {
         let fileURLs = try fileManager.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil)
         //print("fileURLs: \(fileURLs)")
         // process files
      } catch {
         print("Error while enumerating files \(documentsUrl.path): \(error.localizedDescription)")
         spinner.stopAnimation(nil) 
      }
      spinner.stopAnimation(nil) 
      let string = "aaa"
      let theFileName = (string as NSString).lastPathComponent
   /*
   let filename: String = "your file name"
   let pathExtention = filename.pathExtension
//   let pathPrefix = filename.stringByDeletingPathExtension
   
   let filename = (self.pdfURL as NSString).lastPathComponent  // pdfURL is your file url
   let fileExtention = (filename as NSString).pathExtension  // get your file extension
   let pathPrefix = (filename as NSString).deletingPathExtension   // File name without extension
   
      var lblFileName.text = pathPrefix  // Print name on Label
   */
   }
   
   override var representedObject: Any? {
      didSet {
      // Update the view, if already loaded.
      }
   }


}

