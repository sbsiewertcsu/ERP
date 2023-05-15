import {Component, OnInit} from '@angular/core';
import * as leaflet from 'leaflet';
import 'heatmap.js';
import heatData from '../assets/data/sales.json';

declare const HeatmapOverlay: any;

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit {
  private map: any;

  ngOnInit(): void {
    this.initMap();
  }

  private initMap(): void {
    // Initialising map with center point by using the coordinates
    // Setting initial zoom to 3
    //center: [ 39.2745, -76.611 ],
    this.map = leaflet.map('map', {
      center: [ 39.6932, -121.8281 ],
      zoom: 16
    });

    // Initialising tiles to the map by using openstreetmap
    // Setting zoom levels
    const tiles = leaflet.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 18,
      minZoom: 3,
      attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    });

    // Adding tiles to the map
    tiles.addTo(this.map);

    // Setting up heat layer config
    const heatLayerConfig = {
      "radius": 20,
      "maxOpacity": .8,
      "scaleRadius": false,
      // property below responsible for colorization of heat layer
      "useLocalExtrema": true,
      // here we need to assign property value which represent lat in our data
      latField: 'lat',
      // here we need to assign property value which represent lng in our data
      lngField: 'lng',
      // here we need to assign property value which represent valueField in our data
      valueField: 'db'
    };

    // Initialising heat layer and passing config
    const heatmapLayer = new HeatmapOverlay(heatLayerConfig);
    const min = Math.min(...heatData.map(sale => sale.db))
    const max = Math.max(...heatData.map(sale => sale.db))
    const heat_data = heatData.map(sale => {
      return { 
        lat: +sale.lat, 
        lng: +sale.lng, 
        db: sale.db
      }
    });
    //Passing data to a layer
    heatmapLayer.setData({
      min: min,
      max: max,
      data: heat_data
    });

    //Adding heat layer to a map
    heatmapLayer.addTo(this.map);
  }
}
