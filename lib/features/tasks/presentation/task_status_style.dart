import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../models/task.dart';

Color taskStatusColor(TaskStatus status) {
  return switch (status) {
    TaskStatus.pending => AppTheme.navyMuted,
    TaskStatus.inProgress => AppTheme.warning,
    TaskStatus.completed => AppTheme.success,
    TaskStatus.cancelled => AppTheme.danger,
    TaskStatus.overdue => AppTheme.danger,
  };
}

Color taskPriorityColor(TaskPriority priority) {
  return switch (priority) {
    TaskPriority.low => AppTheme.navyMuted,
    TaskPriority.medium => AppTheme.navy,
    TaskPriority.high => AppTheme.warning,
    TaskPriority.critical => AppTheme.danger,
  };
}
