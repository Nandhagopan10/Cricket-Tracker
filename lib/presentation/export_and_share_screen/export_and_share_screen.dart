import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../../../core/app_export.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_icon_widget.dart';
import 'widgets/export_option_card_widget.dart';
import 'widgets/export_progress_widget.dart';
import 'widgets/generated_file_card_widget.dart';

class ExportAndShareScreen extends StatefulWidget {
  const ExportAndShareScreen({super.key});

  @override
  State<ExportAndShareScreen> createState() => _ExportAndShareScreenState();
}

class _ExportAndShareScreenState extends State<ExportAndShareScreen> {
  bool _isExporting = false;
  double _exportProgress = 0.0;
  String _currentOperation = '';
  final List<GeneratedFile> _generatedFiles = [];
  String? _selectedFileId;

  // Mock session data for export
  final Map<String, dynamic> _sessionData = {
    "sessionId": "SESSION_2026_01_26_001",
    "playerName": "Virat Kohli",
    "playerRole": "Batsman",
    "date": "26/01/2026",
    "duration": "45 minutes",
    "totalDeliveries": 120,
    "metrics": {
      "batting": {
        "avgBatSpeed": "85.4 km/h",
        "peakBatSpeed": "102.3 km/h",
        "avgImpactSpeed": "78.2 km/h",
        "peakImpactSpeed": "95.7 km/h",
        "avgBatAngle": "42.5°",
        "consistency": "87%",
      },
    },
    "insights": [
      "Peak performance achieved in middle session (15-30 min)",
      "Bat speed consistency improved by 12% compared to last session",
      "Optimal impact angle maintained in 87% of deliveries",
    ],
    "timestamps": [
      {
        "time": "00:00:15",
        "batSpeed": 82.3,
        "impactSpeed": 75.1,
        "angle": 41.2,
      },
      {
        "time": "00:00:30",
        "batSpeed": 85.7,
        "impactSpeed": 78.5,
        "angle": 43.1,
      },
      {
        "time": "00:00:45",
        "batSpeed": 88.2,
        "impactSpeed": 80.3,
        "angle": 42.8,
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          title: 'Export & Share',
          leading: IconButton(
            icon: CustomIconWidget(
              iconName: 'arrow_back',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: SafeArea(
        child: _isExporting
            ? _buildExportingView(theme)
            : _buildMainView(theme),
      ),
    );
  }

  Widget _buildMainView(ThemeData theme) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Options',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 2.h),
            _buildExportOptionsSection(theme),
            SizedBox(height: 3.h),
            _generatedFiles.isNotEmpty
                ? _buildGeneratedFilesSection(theme)
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOptionsSection(ThemeData theme) {
    return Column(
      children: [
        ExportOptionCardWidget(
          title: 'CSV Data Export',
          description: 'Export raw sensor data and calculated metrics',
          icon: 'table_chart',
          fileFormat: 'CSV',
          estimatedSize: '2.4 MB',
          includedFields: [
            'Timestamps',
            'Bat Speed',
            'Impact Speed',
            'Bat Angle',
            'Calculated Metrics',
          ],
          onTap: () => _handleExport('csv'),
        ),
        SizedBox(height: 2.h),
        ExportOptionCardWidget(
          title: 'PDF Report',
          description: 'Generate comprehensive performance report',
          icon: 'picture_as_pdf',
          fileFormat: 'PDF',
          estimatedSize: '1.8 MB',
          includedFields: [
            'Session Summary',
            'Performance Charts',
            'Insights & Analysis',
            'Player Information',
          ],
          onTap: () => _handleExport('pdf'),
        ),
      ],
    );
  }

  Widget _buildGeneratedFilesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Generated Files',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 2.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _generatedFiles.length,
          separatorBuilder: (context, index) => SizedBox(height: 1.5.h),
          itemBuilder: (context, index) {
            final file = _generatedFiles[index];
            return GeneratedFileCardWidget(
              file: file,
              isSelected: _selectedFileId == file.id,
              onTap: () => _handleFileSelection(file.id),
              onShare: () => _handleShare(file),
              onDelete: () => _handleDelete(file.id),
            );
          },
        ),
      ],
    );
  }

  Widget _buildExportingView(ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: ExportProgressWidget(
          progress: _exportProgress,
          currentOperation: _currentOperation,
          onCancel: _handleCancelExport,
        ),
      ),
    );
  }

  Future<void> _handleExport(String format) async {
    setState(() {
      _isExporting = true;
      _exportProgress = 0.0;
      _currentOperation = 'Initializing export...';
    });

    try {
      if (format == 'csv') {
        await _exportCSV();
      } else if (format == 'pdf') {
        await _exportPDF();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
          _exportProgress = 0.0;
          _currentOperation = '';
        });
      }
    }
  }

  Future<void> _exportCSV() async {
    setState(() => _currentOperation = 'Preparing CSV data...');
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _exportProgress = 0.3);

    final csvContent = _generateCSVContent();

    setState(() => _currentOperation = 'Writing CSV file...');
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _exportProgress = 0.6);

    final filename =
        'session_${_sessionData["sessionId"]}_${DateTime.now().millisecondsSinceEpoch}.csv';

    setState(() => _currentOperation = 'Saving file...');
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _exportProgress = 0.9);

    Directory? directory;
    if (!kIsWeb) {
      directory = await getApplicationDocumentsDirectory();
    }

    if (kIsWeb) {
      final bytes = utf8.encode(csvContent);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final file = File('${directory!.path}/$filename');
      await file.writeAsString(csvContent);
    }

    setState(() {
      _exportProgress = 1.0;
      _currentOperation = 'Export completed!';
      _generatedFiles.add(
        GeneratedFile(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: filename,
          format: 'CSV',
          size: '${(csvContent.length / 1024).toStringAsFixed(1)} KB',
          createdAt: DateTime.now(),
          path: kIsWeb ? null : '${directory!.path}/$filename',
        ),
      );
    });

    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _exportPDF() async {
    setState(() => _currentOperation = 'Preparing PDF document...');
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _exportProgress = 0.3);

    final pdf = pw.Document();

    setState(() => _currentOperation = 'Generating report content...');
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _exportProgress = 0.6);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Cricket Performance Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Session ID: ${_sessionData["sessionId"]}'),
              pw.Text('Player: ${_sessionData["playerName"]}'),
              pw.Text('Role: ${_sessionData["playerRole"]}'),
              pw.Text('Date: ${_sessionData["date"]}'),
              pw.Text('Duration: ${_sessionData["duration"]}'),
              pw.SizedBox(height: 20),
              pw.Text(
                'Performance Metrics',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Average Bat Speed: ${_sessionData["metrics"]["batting"]["avgBatSpeed"]}',
              ),
              pw.Text(
                'Peak Bat Speed: ${_sessionData["metrics"]["batting"]["peakBatSpeed"]}',
              ),
              pw.Text(
                'Average Impact Speed: ${_sessionData["metrics"]["batting"]["avgImpactSpeed"]}',
              ),
              pw.Text(
                'Peak Impact Speed: ${_sessionData["metrics"]["batting"]["peakImpactSpeed"]}',
              ),
              pw.Text(
                'Average Bat Angle: ${_sessionData["metrics"]["batting"]["avgBatAngle"]}',
              ),
              pw.Text(
                'Consistency: ${_sessionData["metrics"]["batting"]["consistency"]}',
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Key Insights',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              ...(_sessionData["insights"] as List).map(
                (insight) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 5),
                  child: pw.Text('• $insight'),
                ),
              ),
            ],
          );
        },
      ),
    );

    setState(() => _currentOperation = 'Saving PDF file...');
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _exportProgress = 0.9);

    final filename =
        'report_${_sessionData["sessionId"]}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final bytes = await pdf.save();

    Directory? directory;
    if (!kIsWeb) {
      directory = await getApplicationDocumentsDirectory();
    }

    if (kIsWeb) {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final file = File('${directory!.path}/$filename');
      await file.writeAsBytes(bytes);
    }

    setState(() {
      _exportProgress = 1.0;
      _currentOperation = 'Export completed!';
      _generatedFiles.add(
        GeneratedFile(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: filename,
          format: 'PDF',
          size: '${(bytes.length / 1024).toStringAsFixed(1)} KB',
          createdAt: DateTime.now(),
          path: kIsWeb ? null : '${directory!.path}/$filename',
        ),
      );
    });

    await Future.delayed(const Duration(milliseconds: 500));
  }

  String _generateCSVContent() {
    final buffer = StringBuffer();
    buffer.writeln(
      'Session ID,Player Name,Player Role,Date,Duration,Total Deliveries',
    );
    buffer.writeln(
      '${_sessionData["sessionId"]},${_sessionData["playerName"]},${_sessionData["playerRole"]},${_sessionData["date"]},${_sessionData["duration"]},${_sessionData["totalDeliveries"]}',
    );
    buffer.writeln('');
    buffer.writeln(
      'Timestamp,Bat Speed (km/h),Impact Speed (km/h),Bat Angle (degrees)',
    );

    for (final entry in _sessionData["timestamps"] as List) {
      buffer.writeln(
        '${entry["time"]},${entry["batSpeed"]},${entry["impactSpeed"]},${entry["angle"]}',
      );
    }

    buffer.writeln('');
    buffer.writeln('Performance Summary');
    buffer.writeln('Metric,Value');
    buffer.writeln(
      'Average Bat Speed,${_sessionData["metrics"]["batting"]["avgBatSpeed"]}',
    );
    buffer.writeln(
      'Peak Bat Speed,${_sessionData["metrics"]["batting"]["peakBatSpeed"]}',
    );
    buffer.writeln(
      'Average Impact Speed,${_sessionData["metrics"]["batting"]["avgImpactSpeed"]}',
    );
    buffer.writeln(
      'Peak Impact Speed,${_sessionData["metrics"]["batting"]["peakImpactSpeed"]}',
    );
    buffer.writeln(
      'Average Bat Angle,${_sessionData["metrics"]["batting"]["avgBatAngle"]}',
    );
    buffer.writeln(
      'Consistency,${_sessionData["metrics"]["batting"]["consistency"]}',
    );

    return buffer.toString();
  }

  void _handleCancelExport() {
    setState(() {
      _isExporting = false;
      _exportProgress = 0.0;
      _currentOperation = '';
    });
  }

  void _handleFileSelection(String fileId) {
    setState(() {
      _selectedFileId = _selectedFileId == fileId ? null : fileId;
    });
  }

  Future<void> _handleShare(GeneratedFile file) async {
    try {
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'File downloaded. Use your browser\'s share feature to share it.',
            ),
          ),
        );
      } else {
        if (file.path != null) {
          await Share.shareXFiles([
            XFile(file.path!),
          ], text: 'Cricket Performance Data - ${file.name}');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to share file. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _handleDelete(String fileId) {
    setState(() {
      _generatedFiles.removeWhere((file) => file.id == fileId);
      if (_selectedFileId == fileId) {
        _selectedFileId = null;
      }
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('File deleted successfully')));
  }
}

class GeneratedFile {
  final String id;
  final String name;
  final String format;
  final String size;
  final DateTime createdAt;
  final String? path;

  GeneratedFile({
    required this.id,
    required this.name,
    required this.format,
    required this.size,
    required this.createdAt,
    this.path,
  });
}
