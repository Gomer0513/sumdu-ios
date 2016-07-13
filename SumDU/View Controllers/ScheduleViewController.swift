//
//  ScheduleViewController.swift
//  SumDU
//
//  Created by Yura on 20.12.15.
//  Copyright © 2015 AppDecAcademy. All rights reserved.
//

import Cartography
import UIKit
import SwiftyJSON

class ScheduleViewController: UIViewController {
    
    // MARK: - Variables
    
    /// Data from SearchController
    private var listData: ListData?
    
    /// Object of Parser class
    private var parser = Parser()
    
    /// Schedule records separated by sections
    private var recordsBySection: [Section] = [] {
        didSet {
            scheduleTableView.reloadData()
        }
    }
    
    /// URL for add schedule events to calendar
    private var calendarURL: NSURL?
    
    // MARK: - UI objects
    
    // Navigation bar
    private let backButton = BackButton()
    private let shareButton = ShareButton()
    private let refreshButton = RefreshButton()
    
    // Content
    private let titleLabel = UILabel()
    private let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    private let informationLabel = UILabel()
    private let refreshControl = UIRefreshControl()
    private let scheduleTableView = UITableView()
    
    // MARK: - Initialization
    
    init(data: ListData) {
        super.init(nibName: nil, bundle: nil)
        
        listData = data
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        let topMargin: CGFloat = 32.0
        let leadingMargin: CGFloat = 14.0
        let trailingMargin: CGFloat = 14.0
        
        // Parser
        parser.scheduleDelegate = self
        
        // Back
        backButton.addTarget(self, action: #selector(backButtonPressed), forControlEvents: .TouchUpInside)
        view.addSubview(backButton)
        constrain(backButton, view) { backButton, superview in
            backButton.top == superview.top + topMargin
            backButton.leading == superview.leading + leadingMargin
            backButton.height == BackButton.buttonSize.height
            backButton.width == BackButton.buttonSize.width
        }
        // Refresh
        refreshButton.addTarget(self, action: #selector(refresh), forControlEvents: .TouchUpInside)
        view.addSubview(refreshButton)
        constrain(refreshButton, view) { refreshButton, superview in
            refreshButton.top == superview.top + topMargin
            refreshButton.trailing == superview.trailing - trailingMargin
            refreshButton.height == RefreshButton.buttonSize.height
            refreshButton.width == RefreshButton.buttonSize.width
        }
        // Share
        shareButton.addTarget(self, action: #selector(share), forControlEvents: .TouchUpInside)
        view.addSubview(shareButton)
        constrain(shareButton, refreshButton, view) { shareButton, refreshButton, superview in
            shareButton.top == superview.top + topMargin
            shareButton.trailing == refreshButton.leading - 20.0
            shareButton.height == ShareButton.buttonSize.height
            shareButton.width == ShareButton.buttonSize.width
        }
        // Title
        titleLabel.font = FontManager.getFont(name: FontName.HelveticaNeueMedium, size: 26.0)
        titleLabel.textColor = Color.textColorBlack
        titleLabel.numberOfLines = 0
        view.addSubview(titleLabel)
        constrain(titleLabel, backButton, view) { titleLabel, backButton, superview in
            titleLabel.top == backButton.bottom
            titleLabel.leading == superview.leading + leadingMargin
            titleLabel.trailing == superview.trailing - trailingMargin
            titleLabel.height >= 96.0
        }
        // Schedule table
        scheduleTableView.registerClass(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.reuseIdentifier)
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        view.addSubview(scheduleTableView)
        constrain(scheduleTableView, titleLabel, view) { scheduleTableView, titleLabel, superview in
            scheduleTableView.top == titleLabel.bottom
            scheduleTableView.leading == superview.leading
            scheduleTableView.trailing == superview.trailing
            scheduleTableView.bottom == superview.bottom
        }
        // Remove separators for empty cells
        scheduleTableView.tableFooterView = UIView()
        
        // Set up the refresh control
        refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to refresh", comment: ""))
        refreshControl.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
        scheduleTableView.addSubview(refreshControl)
        
        // Information
        informationLabel.font = FontManager.getFont(name: FontName.HelveticaNeueMedium, size: 20.0)
        informationLabel.textColor = Color.textColorNormal
        informationLabel.textAlignment = .Center
        informationLabel.adjustsFontSizeToFitWidth = true
        informationLabel.minimumScaleFactor = 0.7
        view.addSubview(informationLabel)
        constrain(informationLabel, view) { informationLabel, superview in
            informationLabel.leading == superview.leading + 20.0
            informationLabel.trailing == superview.trailing - 20.0
            informationLabel.centerY == superview.centerY
        }
        informationLabel.text = NSLocalizedString("Sorry. There are no results for your request.", comment: "")
        informationLabel.hidden = true
        
        // Indicator
        view.addSubview(activityIndicatorView)
        constrain(activityIndicatorView, view) { activityIndicatorView, superview in
            activityIndicatorView.center == superview.center
        }
        
        // Send request
        parser.sendScheduleRequest(listData)
        updateData()
    }
    
    // MARK: - Helpers
    
    private func updateData() {
        if let data = listData {
            titleLabel.text = data.name
        }
    }
    
    // MARK: - Actions
    
    func backButtonPressed() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    /// Refresh schedule table
    func refresh() {
        parser.sendScheduleRequest(listData)
    }
    
    /// Reload schedule, send new request
    func refreshSchedule() {
        parser.sendScheduleRequest(listData)
    }
    
    /// Share schedule
    func share() {
        parser.generateCalendarURL(listData)
        if let url = calendarURL {
            UIApplication.sharedApplication().openURL(url)
        }
    }
}

// MARK: - UITableViewDelegate

extension ScheduleViewController: UITableViewDelegate { }

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        // Create a date formatter
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMMM, EEEE"
        
        // Generate section header
        let sectionHeader = dateFormatter.stringFromDate(recordsBySection[section].date)
        
        return sectionHeader
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return recordsBySection.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordsBySection[section].records.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(ScheduleCell.reuseIdentifier, forIndexPath: indexPath) as! ScheduleCell
        let scheduleRecord = recordsBySection[indexPath.section].records[indexPath.row]
        cell.textLabel?.text = scheduleRecord.pairName
        return cell
    }
}

// MARK: - ParserScheduleDelegate

extension ScheduleViewController: ParserScheduleDelegate {
    
    func getSchedule(response: JSON) {
        
        if !refreshControl.refreshing {
            /// Show request animation
            activityIndicatorView.startAnimating()
        }
        
        if let jsonArray = response.array where jsonArray.count > 0 {
            // All schedule records
            var allScheduleRecords: [Schedule] = []
            
            // All schedule records separated by sections
            var forRecordsBySection: [Section] = []
            
            // Set of the unique schedule dates
            var sectionsDate = [NSDate]()
            
            // Iterate JSON array
            for subJson in jsonArray {
                
                // Init schedule object
                if let scheduleRecord = Schedule(record: subJson) {
                    
                    // Fill dates array
                    sectionsDate.append(scheduleRecord.pairDate)
                    
                    // Fill schedule array
                    allScheduleRecords.append(scheduleRecord)
                }
            }
            // Order set of dates
            let orderedDates = Set(sectionsDate).sort {
                $0.compare($1) == .OrderedAscending
            }
            // Iterate all dates
            for singleDate in orderedDates {
                
                // For schedule records in single section
                var scheduleRecordsInSection: [Schedule] = []
                
                // Iterate all schedule records
                for singleScheduleRecord in allScheduleRecords {
                    
                    // If section date equals date of schedule record
                    if singleDate == singleScheduleRecord.pairDate {
                        
                        // Append schedule record to section array
                        scheduleRecordsInSection.append(singleScheduleRecord)
                    }
                }
                // Sort schedule records in single section by pair order name
                scheduleRecordsInSection.sortInPlace {
                    $0.pairOrderName < $1.pairOrderName
                }
                // Append to array of sections
                forRecordsBySection.append(Section(date: singleDate, records: scheduleRecordsInSection))
            }
            // Move data from temporary var to public
            recordsBySection = forRecordsBySection
        } else {
            informationLabel.hidden = false
            scheduleTableView.hidden = true
        }
        // Tell refresh control it can stop showing up now
        if refreshControl.refreshing {
            refreshControl.endRefreshing()
        } else {
            activityIndicatorView.stopAnimating()
        }
    }
    
    /// Get calendar URL
    func getCalendar(url: NSURL?) {
        calendarURL = url
    }
}
