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
    
    let urlBase = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
    
    @IBOutlet weak var titulo: UITextView!
    
    @IBOutlet weak var autor: UITextView!
    
    @IBOutlet weak var portada: UIImageView!
    
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
                    if (json.count != 0){
                        let dico1 = json as! NSDictionary
                        isbn = "ISBN:"+isbn!
                        let dico2 = dico1[isbn!] as! NSDictionary
                        print("dico2: ",dico2)
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            //  let texto = NSString(data: data, encoding: NSUTF8StringEncoding)
                            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                            // self.titulo.text = dico2
                            self.searchBar.endEditing(true)
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


}

