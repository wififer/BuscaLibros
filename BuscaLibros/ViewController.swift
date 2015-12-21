//
//  ViewController.swift
//  BuscaLibros
//
//  Created by wififer on 06/12/15.
//  Copyright © 2015 wififer. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
   
    
    // https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:978-84-376-0494-7
    // https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:978-84-9928-071-4  COVER
    
    let urlBase = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
    
    @IBOutlet weak var titulo: UITextView!
    
    @IBOutlet weak var autor: UITextView!
    
    @IBOutlet weak var portada: UIImageView!
    var logo = UIImage(named: "portada_libro")

    
    @IBOutlet weak var imgIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()

        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    titulo.text = ""
    autor.text = ""
    portada.image = logo
    
        var isbn = searchBar.text
        let url:NSURL = NSURL(string: urlBase+isbn!)!
        let session = NSURLSession.sharedSession()
    if Reachability.isConnectedToNetwork() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        let task = session.downloadTaskWithURL(url) {
            (
            let location, let response, let error) in
            
            guard let _:NSURL = location, let _:NSURLResponse = response  where error == nil else {
                print("error")
            return
                
            }
            
            if   let data = NSData(contentsOfURL: location!) {
                
                do {
                  let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves)
                    
                    print("json.count: ",json.count)
                    
                    if (json.count != 0) {
                        
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = true

                      var  autorTxt = ""
                        let dico1 = json as! NSDictionary
                        isbn = "ISBN:"+isbn!
                        let dico2 = dico1[isbn!] as! NSDictionary
                        print("dico2: ",dico2)
                        let title = dico2["title"] as! NSString as String
                        print("title: ",title)
                        let autores = dico2["authors"] as! NSArray
                        print("autores: ",autores)
                        for name in autores {
                            
                            if let miAutor = name["name"] {
                                print("miAutor: ",miAutor!)
                                 autorTxt += "\(miAutor!) \n"
                                
                            }
                           
                        }
                        
                        if let p = dico2["cover"] {
                            let portadas = p as! NSDictionary
                            let urlPortada = portadas["large"] as! NSString as String
                            print("portada: ",urlPortada)
                            self.descargarImgPrincipal(urlPortada)
  
                        }
                        
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            //  let texto = NSString(data: data, encoding: NSUTF8StringEncoding)
                             self.titulo.text = title
                            self.autor.text = autorTxt
                            self.searchBar.endEditing(true)
                            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

                        })
                    }else{
                        dispatch_async(dispatch_get_main_queue(), {
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        print("Ningún resultado")
                            self.searchBar.endEditing(true)

                        let alertController = UIAlertController(title: "Atención!", message:
                            "No hay ningún libro con ese ISBN", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default,handler: nil))
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                              })
                    }
                  

                }catch _{
                    
                }
                
                           }
        }
        task.resume()
    }else {
        print("Internet connection not available")
        let alertController = UIAlertController(title: "Atención!", message:
            "No hay conexión a internet", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
        
    
}
    
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
         self.searchBar.endEditing(true)
    }
    
    func descargarImgPrincipal(url:String) {
        
        dispatch_async(dispatch_get_main_queue(), {
            self.imgIndicator.startAnimating()
        })

                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { ()
                    
                    
                    let url:NSURL = NSURL(string: url)!
                    let session = NSURLSession.sharedSession()
                    
                    let task = session.downloadTaskWithURL(url) {
                        (
                        let location, let response, let error) in
                        
                        guard let _:NSURL = location, let _:NSURLResponse = response  where error == nil else {
                            print("error")
                            return
                        }
                        
                        if   let imageData = NSData(contentsOfURL: location!) {
                            guard let image = UIImage(data: imageData) else {
                                // throw an error, return from your function, whatever
                                print ("fallo en : ",url)
                                return
                            }
                            
                                    dispatch_async(dispatch_get_main_queue(), {
                                          print("Pongo imagen:  \(image)")
                                        self.portada.image = image
                                        self.imgIndicator.stopAnimating()

                                        return
                                    })
                        
                        }
                        
                    }
                    
                    task.resume()
                })
 
        
    }



}

